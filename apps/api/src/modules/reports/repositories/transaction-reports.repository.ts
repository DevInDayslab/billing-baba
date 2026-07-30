import {
  and,
  count,
  desc,
  eq,
  gte,
  ilike,
  inArray,
  lt,
  or,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { payments } from '../../../db/schema/accounting/tables';
import { parties } from '../../../db/schema/crm/tables';
import { items } from '../../../db/schema/inventory/tables';
import {
  salesDocumentLines,
  salesDocuments,
} from '../../../db/schema/sales/tables';
import { REVENUE_SALES_TYPES } from '../../../shared/reporting/constants';
import type { ReportExtendedQuery } from '../reports.schema';
import type {
  BillWiseProfitPayload,
  CashFlowPayload,
  ReportTransactionRow,
} from '../reports.types';
import { Phase1ReportsRepository } from './phase1-reports.repository';
import { paginateSlice, resolveRange, toPeriodMeta } from './reports.helpers';

export class TransactionReportsRepository {
  private readonly phase1: Phase1ReportsRepository;

  constructor(private readonly db: Database) {
    this.phase1 = new Phase1ReportsRepository(db);
  }

  async getBillWiseProfit(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: BillWiseProfitPayload; total: number }> {
    const range = resolveRange(query);

    const filters = [
      eq(salesDocuments.businessId, businessId),
      eq(salesDocuments.isDeleted, false),
      eq(salesDocuments.status, 'finalized'),
      inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
      gte(salesDocuments.documentDate, range.from),
      lt(salesDocuments.documentDate, range.to),
    ];

    if (query.party_id) {
      filters.push(eq(salesDocuments.partyId, query.party_id));
    }
    if (query.document_type) {
      filters.push(
        eq(salesDocuments.documentType, query.document_type as never),
      );
    }
    if (query.q) {
      filters.push(
        or(
          ilike(salesDocuments.documentNumber, `%${query.q}%`),
          ilike(parties.name, `%${query.q}%`),
        )!,
      );
    }
    if (query.party_group) {
      filters.push(eq(parties.partyCategory, query.party_group));
    }

    const whereClause = and(...filters);

    const [countRow] = await this.db
      .select({ total: count() })
      .from(salesDocuments)
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(whereClause);
    const total = Number(countRow?.total ?? 0);
    const offset = (query.page - 1) * query.limit;

    const rows = await this.db
      .select({
        documentDate: salesDocuments.documentDate,
        documentNumber: salesDocuments.documentNumber,
        partyName: parties.name,
        saleAmount: salesDocuments.totalAmount,
        purchaseAmount: sql<string>`COALESCE(SUM(${salesDocumentLines.quantity}::numeric * ${items.purchasePrice}::numeric), 0)`,
      })
      .from(salesDocuments)
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .leftJoin(
        salesDocumentLines,
        and(
          eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
          eq(salesDocumentLines.isDeleted, false),
        ),
      )
      .leftJoin(items, eq(salesDocumentLines.itemId, items.id))
      .where(whereClause)
      .groupBy(
        salesDocuments.id,
        salesDocuments.documentDate,
        salesDocuments.documentNumber,
        parties.name,
        salesDocuments.totalAmount,
      )
      .orderBy(desc(salesDocuments.documentDate))
      .limit(query.limit)
      .offset(offset);

    const allProfits = rows.map((row) => {
      const sale = Number(row.saleAmount ?? 0);
      const purchase = Number(row.purchaseAmount ?? 0);
      return sale - purchase;
    });
    const totalProfit = allProfits.reduce((sum, value) => sum + value, 0);

    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        total_profit: String(totalProfit),
        rows: rows.map((row) => {
          const saleAmount = Number(row.saleAmount ?? 0);
          const purchaseAmount = Number(row.purchaseAmount ?? 0);
          return {
            date: row.documentDate.toISOString(),
            invoice_no: row.documentNumber ?? '',
            party_name: row.partyName,
            sale_amount: row.saleAmount ?? '0',
            purchase_amount: String(purchaseAmount),
            profit: String(saleAmount - purchaseAmount),
          };
        }),
      },
    };
  }

  async getCashFlow(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: CashFlowPayload; total: number }> {
    const range = resolveRange(query);
    const allRows = await this.phase1.buildTransactionUnion(
      businessId,
      range.from,
      range.to,
      query.party_id,
      query.q,
    );

    const cashRows = allRows.filter(
      (row) => row.payment_type?.toLowerCase() === 'cash',
    );

    const [openingRow] = await this.db
      .select({
        net: sql<string>`COALESCE(SUM(
          CASE
            WHEN ${payments.direction} = 'received' THEN ${payments.amount}::numeric
            ELSE -${payments.amount}::numeric
          END
        ), 0)`,
      })
      .from(payments)
      .where(
        and(
          eq(payments.businessId, businessId),
          eq(payments.isDeleted, false),
          eq(payments.paymentMode, 'cash'),
          lt(payments.paymentDate, range.from),
        ),
      );

    const openingCash = Number(openingRow?.net ?? 0);
    const totalCashIn = cashRows.reduce(
      (sum, row) => sum + Number(row.money_in),
      0,
    );
    const totalCashOut = cashRows.reduce(
      (sum, row) => sum + Number(row.money_out),
      0,
    );
    const closingCash = openingCash + totalCashIn - totalCashOut;

    const { rows, total } = paginateSlice(cashRows, query.page, query.limit);

    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        opening_cash: String(openingCash),
        closing_cash: String(closingCash),
        total_cash_in: String(totalCashIn),
        total_cash_out: String(totalCashOut),
        rows: rows as ReportTransactionRow[],
      },
    };
  }
}
