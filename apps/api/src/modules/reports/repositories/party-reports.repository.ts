import {
  and,
  desc,
  eq,
  gte,
  ilike,
  inArray,
  lt,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { parties } from '../../../db/schema/crm/tables';
import { items } from '../../../db/schema/inventory/tables';
import {
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
  ReportPartyByItemRow,
  ReportPartyWiseProfitLossRow,
  ReportSalePurchaseByPartyGroupRow,
  ReportSalePurchaseByPartyRow,
} from '../reports.types';
import { paginateSlice, resolveRange, toPeriodMeta } from './reports.helpers';

export class PartyReportsRepository {
  constructor(private readonly db: Database) {}

  private partyGroupFilter(query: ReportExtendedQuery) {
    return query.party_group
      ? eq(parties.partyCategory, query.party_group)
      : undefined;
  }

  async getPartyWiseProfitLoss(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportPartyWiseProfitLossRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const saleAgg = this.db
      .select({
        partyId: salesDocuments.partyId,
        saleAmount: sql<string>`COALESCE(SUM(${salesDocuments.totalAmount}::numeric), 0)`.as(
          'sale_amount',
        ),
        purchaseCost: sql<string>`COALESCE(SUM(${salesDocumentLines.quantity}::numeric * ${items.purchasePrice}::numeric), 0)`.as(
          'purchase_cost',
        ),
      })
      .from(salesDocuments)
      .leftJoin(
        salesDocumentLines,
        and(
          eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
          eq(salesDocumentLines.isDeleted, false),
        ),
      )
      .leftJoin(items, eq(salesDocumentLines.itemId, items.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .groupBy(salesDocuments.partyId)
      .as('sale_agg');

    const purchaseAgg = this.db
      .select({
        partyId: purchaseDocuments.partyId,
        purchaseAmount: sql<string>`COALESCE(SUM(${purchaseDocuments.totalAmount}::numeric), 0)`.as(
          'purchase_amount',
        ),
      })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
        ),
      )
      .groupBy(purchaseDocuments.partyId)
      .as('purchase_agg');

    const partyFilters = [
      eq(parties.businessId, businessId),
      eq(parties.isDeleted, false),
    ];
    const partyGroupFilter = this.partyGroupFilter(query);
    if (partyGroupFilter) {
      partyFilters.push(partyGroupFilter);
    }
    if (query.q) {
      partyFilters.push(ilike(parties.name, `%${query.q}%`));
    }

    const rows = await this.db
      .select({
        partyName: parties.name,
        phone: parties.mobile,
        saleAmount: sql<string>`COALESCE(${saleAgg.saleAmount}, 0)`,
        purchaseAmount: sql<string>`COALESCE(${purchaseAgg.purchaseAmount}, 0)`,
        costAmount: sql<string>`COALESCE(${saleAgg.purchaseCost}, 0)`,
      })
      .from(parties)
      .leftJoin(saleAgg, eq(saleAgg.partyId, parties.id))
      .leftJoin(purchaseAgg, eq(purchaseAgg.partyId, parties.id))
      .where(and(...partyFilters))
      .orderBy(desc(parties.name));

    const mapped = rows
      .map((row) => {
        const sale = Number(row.saleAmount ?? 0);
        const purchase = Number(row.purchaseAmount ?? 0);
        const cost = Number(row.costAmount ?? 0);
        return {
          party_name: row.partyName,
          phone: row.phone,
          sale_amount: String(sale),
          purchase_amount: String(purchase + cost),
          profit: String(sale - purchase - cost),
        };
      })
      .filter((row) => Number(row.sale_amount) > 0 || Number(row.purchase_amount) > 0);

    const { rows: pageRows, total } = paginateSlice(mapped, query.page, query.limit);

    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        rows: pageRows,
      },
    };
  }

  async getPartyReportByItem(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportPartyByItemRow>;
    total: number;
  }> {
    const range = resolveRange(query);
    if (!query.item_id) {
      return {
        total: 0,
        payload: { period: toPeriodMeta(range), rows: [] },
      };
    }

    const filters = [
      eq(salesDocuments.businessId, businessId),
      eq(salesDocuments.isDeleted, false),
      eq(salesDocuments.status, 'finalized'),
      inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
      eq(salesDocumentLines.itemId, query.item_id),
      eq(salesDocumentLines.isDeleted, false),
      gte(salesDocuments.documentDate, range.from),
      lt(salesDocuments.documentDate, range.to),
    ];
    if (query.party_id) {
      filters.push(eq(salesDocuments.partyId, query.party_id));
    }

    const grouped = await this.db
      .select({
        partyName: parties.name,
        quantity: sql<string>`COALESCE(SUM(${salesDocumentLines.quantity}::numeric), 0)`,
        amount: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`,
      })
      .from(salesDocumentLines)
      .innerJoin(
        salesDocuments,
        eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
      )
      .innerJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(and(...filters))
      .groupBy(parties.id, parties.name)
      .orderBy(desc(sql`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`));

    const mapped = grouped.map((row) => ({
      party_name: row.partyName ?? '',
      quantity: row.quantity ?? '0',
      amount: row.amount ?? '0',
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);

    return {
      total,
      payload: { period: toPeriodMeta(range), rows },
    };
  }

  async getSalePurchaseByParty(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportSalePurchaseByPartyRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const saleAgg = this.db
      .select({
        partyId: salesDocuments.partyId,
        saleAmount: sql<string>`COALESCE(SUM(${salesDocuments.totalAmount}::numeric), 0)`.as(
          'sale_amount',
        ),
      })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .groupBy(salesDocuments.partyId)
      .as('sale_agg');

    const purchaseAgg = this.db
      .select({
        partyId: purchaseDocuments.partyId,
        purchaseAmount: sql<string>`COALESCE(SUM(${purchaseDocuments.totalAmount}::numeric), 0)`.as(
          'purchase_amount',
        ),
      })
      .from(purchaseDocuments)
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
        ),
      )
      .groupBy(purchaseDocuments.partyId)
      .as('purchase_agg');

    const partyFilters = [
      eq(parties.businessId, businessId),
      eq(parties.isDeleted, false),
    ];
    if (query.q) {
      partyFilters.push(ilike(parties.name, `%${query.q}%`));
    }

    const rows = await this.db
      .select({
        partyName: parties.name,
        saleAmount: sql<string>`COALESCE(${saleAgg.saleAmount}, 0)`,
        purchaseAmount: sql<string>`COALESCE(${purchaseAgg.purchaseAmount}, 0)`,
      })
      .from(parties)
      .leftJoin(saleAgg, eq(saleAgg.partyId, parties.id))
      .leftJoin(purchaseAgg, eq(purchaseAgg.partyId, parties.id))
      .where(and(...partyFilters));

    const mapped = rows
      .map((row) => ({
        party_name: row.partyName,
        sale_amount: row.saleAmount ?? '0',
        purchase_amount: row.purchaseAmount ?? '0',
      }))
      .filter(
        (row) => Number(row.sale_amount) > 0 || Number(row.purchase_amount) > 0,
      );

    const { rows: pageRows, total } = paginateSlice(mapped, query.page, query.limit);

    return {
      total,
      payload: { period: toPeriodMeta(range), rows: pageRows },
    };
  }

  async getSalePurchaseByPartyGroup(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportSalePurchaseByPartyGroupRow>;
    total: number;
  }> {
    const { payload, total } = await this.getSalePurchaseByParty(
      businessId,
      query,
    );

    const partyRows = await this.db
      .select({
        name: parties.name,
        partyCategory: parties.partyCategory,
      })
      .from(parties)
      .where(
        and(eq(parties.businessId, businessId), eq(parties.isDeleted, false)),
      );

    const categoryMap = new Map(
      partyRows.map((row) => [row.name, row.partyCategory ?? 'custom']),
    );

    const mapped = payload.rows.map((row) => ({
      party_group: categoryMap.get(row.party_name) ?? 'custom',
      party_name: row.party_name,
      sale_amount: row.sale_amount,
      purchase_amount: row.purchase_amount,
    }));

    if (query.party_group) {
      const filtered = mapped.filter((row) => row.party_group === query.party_group);
      const { rows, total: filteredTotal } = paginateSlice(
        filtered,
        query.page,
        query.limit,
      );
      return {
        total: filteredTotal,
        payload: { period: payload.period, rows },
      };
    }

    return { total, payload: { period: payload.period, rows: mapped } };
  }
}
