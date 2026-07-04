import { and, desc, eq, gte, inArray, lt, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { items } from '../../../db/schema/inventory/tables';
import {
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
  Gstr9Payload,
  PaginatedRowsPayload,
  ReportHsnRow,
  ReportSacRow,
} from '../reports.types';
import { paginateSlice, resolveRange, toPeriodMeta } from './reports.helpers';
import { Phase1ReportsRepository } from './phase1-reports.repository';

export class GstReportsRepository {
  private readonly phase1: Phase1ReportsRepository;

  constructor(private readonly db: Database) {
    this.phase1 = new Phase1ReportsRepository(db);
  }

  async getGstr9(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<Gstr9Payload> {
    const range = resolveRange(query);
    const gstr3b = await this.phase1.getGstr3b(businessId, query);

    return {
      period: toPeriodMeta(range),
      rows: gstr3b.rows.map((row) => ({
        label: row.nature,
        taxable_value: row.taxable_value,
        integrated_tax: row.integrated_tax,
        central_tax: row.central_tax,
        state_tax: row.state_tax,
        cess: row.cess,
      })),
    };
  }

  async getSaleSummaryByHsn(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: PaginatedRowsPayload<ReportHsnRow>; total: number }> {
    const range = resolveRange(query);

    const filters = [
      eq(salesDocuments.businessId, businessId),
      eq(salesDocuments.isDeleted, false),
      eq(salesDocuments.status, 'finalized'),
      inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
      eq(salesDocumentLines.isDeleted, false),
      gte(salesDocuments.documentDate, range.from),
      lt(salesDocuments.documentDate, range.to),
    ];
    if (query.tax_rate !== undefined) {
      filters.push(eq(salesDocumentLines.taxRate, String(query.tax_rate)));
    }

    const grouped = await this.db
      .select({
        hsn: items.hsnCode,
        description: items.name,
        uqc: salesDocumentLines.unit,
        quantity: sql<string>`COALESCE(SUM(${salesDocumentLines.quantity}::numeric), 0)`,
        totalValue: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`,
        taxableValue: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric - ${salesDocumentLines.igstAmount}::numeric - ${salesDocumentLines.cgstAmount}::numeric - ${salesDocumentLines.sgstAmount}::numeric), 0)`,
        igst: sql<string>`COALESCE(SUM(${salesDocumentLines.igstAmount}::numeric), 0)`,
        cgst: sql<string>`COALESCE(SUM(${salesDocumentLines.cgstAmount}::numeric), 0)`,
        sgst: sql<string>`COALESCE(SUM(${salesDocumentLines.sgstAmount}::numeric), 0)`,
      })
      .from(salesDocumentLines)
      .innerJoin(
        salesDocuments,
        eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
      )
      .innerJoin(items, eq(salesDocumentLines.itemId, items.id))
      .where(and(...filters))
      .groupBy(items.hsnCode, items.name, salesDocumentLines.unit)
      .orderBy(desc(sql`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`));

    const mapped: ReportHsnRow[] = grouped.map((row) => ({
      hsn: row.hsn ?? '',
      description: row.description ?? '',
      uqc: row.uqc ?? '',
      quantity: row.quantity ?? '0',
      total_value: row.totalValue ?? '0',
      taxable_value: row.taxableValue ?? '0',
      igst: row.igst ?? '0',
      cgst: row.cgst ?? '0',
      sgst: row.sgst ?? '0',
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);

    return {
      total,
      payload: { period: toPeriodMeta(range), rows },
    };
  }

  async getSacReport(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: PaginatedRowsPayload<ReportSacRow>; total: number }> {
    const range = resolveRange(query);

    const grouped = await this.db
      .select({
        sac: items.hsnCode,
        invoiceType: salesDocuments.isGstFormal,
        totalValue: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`,
        taxableValue: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric - ${salesDocumentLines.igstAmount}::numeric - ${salesDocumentLines.cgstAmount}::numeric - ${salesDocumentLines.sgstAmount}::numeric), 0)`,
        igst: sql<string>`COALESCE(SUM(${salesDocumentLines.igstAmount}::numeric), 0)`,
        cgst: sql<string>`COALESCE(SUM(${salesDocumentLines.cgstAmount}::numeric), 0)`,
        sgst: sql<string>`COALESCE(SUM(${salesDocumentLines.sgstAmount}::numeric), 0)`,
      })
      .from(salesDocumentLines)
      .innerJoin(
        salesDocuments,
        eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
      )
      .innerJoin(items, eq(salesDocumentLines.itemId, items.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
          eq(salesDocumentLines.isDeleted, false),
          eq(items.itemType, 'service'),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .groupBy(items.hsnCode, salesDocuments.isGstFormal)
      .orderBy(desc(sql`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`));

    const mapped: ReportSacRow[] = grouped.map((row) => ({
      sac: row.sac ?? '',
      invoice_type: row.invoiceType ? 'B2B' : 'B2C',
      total_value: row.totalValue ?? '0',
      taxable_value: row.taxableValue ?? '0',
      igst: row.igst ?? '0',
      cgst: row.cgst ?? '0',
      sgst: row.sgst ?? '0',
      cess: '0',
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);

    return {
      total,
      payload: { period: toPeriodMeta(range), rows },
    };
  }
}
