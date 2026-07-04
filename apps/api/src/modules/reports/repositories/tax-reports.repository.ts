import { and, eq, gte, ilike, inArray, lt, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { parties } from '../../../db/schema/crm/tables';
import {
  expenses,
  purchaseDocumentLines,
  purchaseDocuments,
} from '../../../db/schema/purchases/tables';
import {
  salesDocumentLines,
  salesDocuments,
} from '../../../db/schema/sales/tables';
import {
  PURCHASE_BILL_TYPE,
  REVENUE_SALES_TYPES,
} from '../../../shared/reporting/constants';
import type { ReportExtendedQuery } from '../reports.schema';
import type {
  PaginatedRowsPayload,
  ReportGstTaxPartyRow,
  ReportGstTaxRateRow,
} from '../reports.types';
import { paginateSlice, resolveRange, toPeriodMeta } from './reports.helpers';

export class TaxReportsRepository {
  constructor(private readonly db: Database) {}

  private emptyPaginated<T>(query: ReportExtendedQuery): {
    payload: PaginatedRowsPayload<T>;
    total: number;
  } {
    return {
      total: 0,
      payload: {
        period: toPeriodMeta(resolveRange(query)),
        rows: [],
      },
    };
  }

  async getGstReport(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportGstTaxPartyRow>;
    total: number;
  }> {
    const range = resolveRange(query);
    const partyFilter = query.q
      ? ilike(parties.name, `%${query.q}%`)
      : undefined;

    const saleTaxByParty = await this.db
      .select({
        partyId: salesDocuments.partyId,
        partyName: parties.name,
        saleTax: sql<string>`COALESCE(SUM(${salesDocuments.taxAmount}::numeric), 0)`,
      })
      .from(salesDocuments)
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
          partyFilter,
        ),
      )
      .groupBy(salesDocuments.partyId, parties.name);

    const purchaseTaxByParty = await this.db
      .select({
        partyId: purchaseDocuments.partyId,
        partyName: parties.name,
        purchaseTax: sql<string>`COALESCE(SUM(${purchaseDocuments.taxAmount}::numeric), 0)`,
      })
      .from(purchaseDocuments)
      .innerJoin(parties, eq(purchaseDocuments.partyId, parties.id))
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
          partyFilter,
        ),
      )
      .groupBy(purchaseDocuments.partyId, parties.name);

    const expenseTaxByParty = await this.db
      .select({
        partyId: expenses.partyId,
        partyName: parties.name,
        expenseTax: sql<string>`COALESCE(SUM(${expenses.taxAmount}::numeric), 0)`,
      })
      .from(expenses)
      .leftJoin(parties, eq(expenses.partyId, parties.id))
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
          gte(expenses.expenseDate, range.from.toISOString().slice(0, 10)),
          lt(expenses.expenseDate, range.to.toISOString().slice(0, 10)),
          partyFilter,
        ),
      )
      .groupBy(expenses.partyId, parties.name);

    const merged = new Map<string, ReportGstTaxPartyRow>();

    for (const row of saleTaxByParty) {
      const name = row.partyName ?? 'Walk-in Customer';
      const existing = merged.get(name) ?? {
        party_name: name,
        sale_tax: '0',
        purchase_expense_tax: '0',
      };
      existing.sale_tax = String(
        Number(existing.sale_tax) + Number(row.saleTax ?? 0),
      );
      merged.set(name, existing);
    }

    for (const row of purchaseTaxByParty) {
      const name = row.partyName ?? 'Unknown';
      const existing = merged.get(name) ?? {
        party_name: name,
        sale_tax: '0',
        purchase_expense_tax: '0',
      };
      existing.purchase_expense_tax = String(
        Number(existing.purchase_expense_tax) + Number(row.purchaseTax ?? 0),
      );
      merged.set(name, existing);
    }

    for (const row of expenseTaxByParty) {
      const name = row.partyName ?? 'Expense';
      const existing = merged.get(name) ?? {
        party_name: name,
        sale_tax: '0',
        purchase_expense_tax: '0',
      };
      existing.purchase_expense_tax = String(
        Number(existing.purchase_expense_tax) + Number(row.expenseTax ?? 0),
      );
      merged.set(name, existing);
    }

    const allRows = [...merged.values()].sort((a, b) =>
      a.party_name.localeCompare(b.party_name),
    );
    const { rows, total } = paginateSlice(allRows, query.page, query.limit);

    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        rows,
      },
    };
  }

  async getGstRateReport(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportGstTaxRateRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const saleByRate = await this.db
      .select({
        taxRate: salesDocumentLines.taxRate,
        taxableSale: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric - ${salesDocumentLines.igstAmount}::numeric - ${salesDocumentLines.cgstAmount}::numeric - ${salesDocumentLines.sgstAmount}::numeric), 0)`,
        taxIn: sql<string>`COALESCE(SUM(${salesDocumentLines.igstAmount}::numeric + ${salesDocumentLines.cgstAmount}::numeric + ${salesDocumentLines.sgstAmount}::numeric), 0)`,
      })
      .from(salesDocumentLines)
      .innerJoin(
        salesDocuments,
        eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
      )
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
          eq(salesDocumentLines.isDeleted, false),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .groupBy(salesDocumentLines.taxRate);

    const purchaseByRate = await this.db
      .select({
        taxRate: purchaseDocumentLines.taxRate,
        taxablePurchase: sql<string>`COALESCE(SUM(${purchaseDocumentLines.lineTotal}::numeric - ${purchaseDocumentLines.igstAmount}::numeric - ${purchaseDocumentLines.cgstAmount}::numeric - ${purchaseDocumentLines.sgstAmount}::numeric), 0)`,
        taxOut: sql<string>`COALESCE(SUM(${purchaseDocumentLines.igstAmount}::numeric + ${purchaseDocumentLines.cgstAmount}::numeric + ${purchaseDocumentLines.sgstAmount}::numeric), 0)`,
      })
      .from(purchaseDocumentLines)
      .innerJoin(
        purchaseDocuments,
        eq(purchaseDocumentLines.purchaseDocumentId, purchaseDocuments.id),
      )
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
          eq(purchaseDocumentLines.isDeleted, false),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
        ),
      )
      .groupBy(purchaseDocumentLines.taxRate);

    const merged = new Map<string, ReportGstTaxRateRow>();

    for (const row of saleByRate) {
      const rate = row.taxRate ?? '0';
      const key = rate;
      const existing = merged.get(key) ?? {
        tax_name: `GST ${rate}%`,
        tax_percent: rate,
        taxable_sale_amount: '0',
        tax_in: '0',
        taxable_purchase_expense_amount: '0',
        tax_out: '0',
      };
      existing.taxable_sale_amount = String(
        Number(existing.taxable_sale_amount) + Number(row.taxableSale ?? 0),
      );
      existing.tax_in = String(
        Number(existing.tax_in) + Number(row.taxIn ?? 0),
      );
      merged.set(key, existing);
    }

    for (const row of purchaseByRate) {
      const rate = row.taxRate ?? '0';
      const key = rate;
      const existing = merged.get(key) ?? {
        tax_name: `GST ${rate}%`,
        tax_percent: rate,
        taxable_sale_amount: '0',
        tax_in: '0',
        taxable_purchase_expense_amount: '0',
        tax_out: '0',
      };
      existing.taxable_purchase_expense_amount = String(
        Number(existing.taxable_purchase_expense_amount) +
          Number(row.taxablePurchase ?? 0),
      );
      existing.tax_out = String(
        Number(existing.tax_out) + Number(row.taxOut ?? 0),
      );
      merged.set(key, existing);
    }

    const allRows = [...merged.values()].sort(
      (a, b) => Number(b.tax_percent) - Number(a.tax_percent),
    );
    const { rows, total } = paginateSlice(allRows, query.page, query.limit);

    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        rows,
      },
    };
  }

  async getForm27eq(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: PaginatedRowsPayload<Record<string, never>>; total: number }> {
    return this.emptyPaginated(query);
  }

  async getTcsReceivable(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: PaginatedRowsPayload<Record<string, never>>; total: number }> {
    return this.emptyPaginated(query);
  }

  async getTdsPayable(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: PaginatedRowsPayload<Record<string, never>>; total: number }> {
    return this.emptyPaginated(query);
  }

  async getTdsReceivable(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: PaginatedRowsPayload<Record<string, never>>; total: number }> {
    return this.emptyPaginated(query);
  }
}
