import { and, desc, eq, gte, inArray, lt, or, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { parties } from '../../../db/schema/crm/tables';
import {
  categories,
  godowns,
  inventoryMovements,
  items,
} from '../../../db/schema/inventory/tables';
import {
  jobWorkOrders,
  jobWorkRawMaterialLines,
} from '../../../db/schema/job-work/tables';
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
import { listStockItemAggregates } from '../../../shared/reporting/inventory-summary';
import type { ReportExtendedQuery } from '../reports.schema';
import type {
  PaginatedRowsPayload,
  ReportCategoryAmountRow,
  ReportConsumptionRow,
  ReportItemByPartyRow,
  ReportItemDetailRow,
  ReportItemDiscountRow,
  ReportItemWiseProfitLossRow,
  ReportManufacturingRow,
  ReportStockDetailRow,
  ReportStockTransferRow,
} from '../reports.types';
import { paginateSlice, resolveRange, toPeriodMeta } from './reports.helpers';

export class ItemReportsRepository {
  constructor(private readonly db: Database) {}

  async getItemReportByParty(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportItemByPartyRow>;
    total: number;
  }> {
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
    if (query.item_id) {
      filters.push(eq(salesDocumentLines.itemId, query.item_id));
    }
    if (query.party_id) {
      filters.push(eq(salesDocuments.partyId, query.party_id));
    }

    const grouped = await this.db
      .select({
        itemName: items.name,
        partyName: parties.name,
        quantity: sql<string>`COALESCE(SUM(${salesDocumentLines.quantity}::numeric), 0)`,
        amount: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`,
      })
      .from(salesDocumentLines)
      .innerJoin(
        salesDocuments,
        eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
      )
      .innerJoin(items, eq(salesDocumentLines.itemId, items.id))
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(and(...filters))
      .groupBy(items.id, items.name, parties.id, parties.name)
      .orderBy(
        desc(sql`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`),
      );

    const mapped = grouped.map((row) => ({
      item_name: row.itemName ?? '',
      party_name: row.partyName ?? '',
      quantity: row.quantity ?? '0',
      amount: row.amount ?? '0',
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getItemWiseProfitLoss(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportItemWiseProfitLossRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const saleAgg = await this.db
      .select({
        itemId: salesDocumentLines.itemId,
        itemName: items.name,
        saleAmount: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`,
        costAmount: sql<string>`COALESCE(SUM(${salesDocumentLines.quantity}::numeric * ${items.purchasePrice}::numeric), 0)`,
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
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .groupBy(salesDocumentLines.itemId, items.name);

    const purchaseAgg = await this.db
      .select({
        itemId: purchaseDocumentLines.itemId,
        purchaseAmount: sql<string>`COALESCE(SUM(${purchaseDocumentLines.lineTotal}::numeric), 0)`,
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
      .groupBy(purchaseDocumentLines.itemId);

    const purchaseMap = new Map(
      purchaseAgg.map((row) => [row.itemId, Number(row.purchaseAmount ?? 0)]),
    );

    const mapped = saleAgg.map((row) => {
      const sale = Number(row.saleAmount ?? 0);
      const purchase = purchaseMap.get(row.itemId) ?? 0;
      const cost = Number(row.costAmount ?? 0);
      return {
        item_name: row.itemName ?? '',
        sale_amount: String(sale),
        purchase_amount: String(purchase + cost),
        profit: String(sale - purchase - cost),
      };
    });

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getStockDetail(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportStockDetailRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const movementFilters = [
      eq(inventoryMovements.businessId, businessId),
      gte(inventoryMovements.createdAt, range.from),
      lt(inventoryMovements.createdAt, range.to),
    ];
    if (query.godown_id) {
      movementFilters.push(eq(inventoryMovements.godownId, query.godown_id));
    }
    if (query.item_id) {
      movementFilters.push(eq(inventoryMovements.itemId, query.item_id));
    }

    const periodAgg = await this.db
      .select({
        itemId: inventoryMovements.itemId,
        itemName: items.name,
        inQty: sql<string>`COALESCE(SUM(CASE WHEN ${inventoryMovements.quantityDelta}::numeric > 0 THEN ${inventoryMovements.quantityDelta}::numeric ELSE 0 END), 0)`,
        outQty: sql<string>`COALESCE(SUM(CASE WHEN ${inventoryMovements.quantityDelta}::numeric < 0 THEN ABS(${inventoryMovements.quantityDelta}::numeric) ELSE 0 END), 0)`,
      })
      .from(inventoryMovements)
      .innerJoin(items, eq(inventoryMovements.itemId, items.id))
      .where(and(...movementFilters))
      .groupBy(inventoryMovements.itemId, items.name);

    const stockResult = await listStockItemAggregates(this.db, businessId, {
      godownId: query.godown_id,
      itemId: query.item_id,
      q: query.q,
      inStockOnly: false,
      page: 1,
      limit: 10_000,
    });

    const stockMap = new Map(
      stockResult.rows.map((row) => [row.itemId, Number(row.totalQty)]),
    );
    const periodMap = new Map(periodAgg.map((row) => [row.itemId, row]));

    const itemIds = new Set([
      ...stockResult.rows.map((row) => row.itemId),
      ...periodAgg.map((row) => row.itemId),
    ]);

    const mapped: ReportStockDetailRow[] = [...itemIds].map((itemId) => {
      const period = periodMap.get(itemId);
      const closing = stockMap.get(itemId) ?? 0;
      const inQty = Number(period?.inQty ?? 0);
      const outQty = Number(period?.outQty ?? 0);
      const opening = closing - inQty + outQty;
      return {
        item_name:
          period?.itemName ??
          stockResult.rows.find((r) => r.itemId === itemId)?.itemName ??
          '',
        opening_qty: String(opening),
        in_qty: String(inQty),
        out_qty: String(outQty),
        closing_qty: String(closing),
      };
    });

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getItemDetail(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportItemDetailRow>;
    total: number;
  }> {
    const range = resolveRange(query);
    if (!query.item_id) {
      return { total: 0, payload: { period: toPeriodMeta(range), rows: [] } };
    }

    const saleRows = await this.db
      .select({
        date: salesDocuments.documentDate,
        type: sql<string>`'Sale'`,
        refNo: salesDocuments.documentNumber,
        partyName: parties.name,
        quantity: salesDocumentLines.quantity,
        price: salesDocumentLines.unitPrice,
        amount: salesDocumentLines.lineTotal,
      })
      .from(salesDocumentLines)
      .innerJoin(
        salesDocuments,
        eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
      )
      .leftJoin(parties, eq(salesDocuments.partyId, parties.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          eq(salesDocumentLines.itemId, query.item_id),
          eq(salesDocumentLines.isDeleted, false),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      );

    const purchaseRows = await this.db
      .select({
        date: purchaseDocuments.documentDate,
        type: sql<string>`'Purchase'`,
        refNo: purchaseDocuments.documentNumber,
        partyName: parties.name,
        quantity: purchaseDocumentLines.quantity,
        price: purchaseDocumentLines.unitPrice,
        amount: purchaseDocumentLines.lineTotal,
      })
      .from(purchaseDocumentLines)
      .innerJoin(
        purchaseDocuments,
        eq(purchaseDocumentLines.purchaseDocumentId, purchaseDocuments.id),
      )
      .innerJoin(parties, eq(purchaseDocuments.partyId, parties.id))
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocumentLines.itemId, query.item_id),
          eq(purchaseDocumentLines.isDeleted, false),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
        ),
      );

    const mapped = [...saleRows, ...purchaseRows]
      .map((row) => ({
        date:
          row.date instanceof Date ? row.date.toISOString() : String(row.date),
        type: String(row.type),
        ref_no: row.refNo ?? '',
        party_name: row.partyName,
        quantity: row.quantity ?? '0',
        price: row.price ?? '0',
        amount: row.amount ?? '0',
      }))
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  private async getCategoryAmountRows(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<ReportCategoryAmountRow[]> {
    const range = resolveRange(query);

    const saleAgg = await this.db
      .select({
        categoryId: items.categoryId,
        categoryName: categories.name,
        saleAmount: sql<string>`COALESCE(SUM(${salesDocumentLines.lineTotal}::numeric), 0)`,
      })
      .from(salesDocumentLines)
      .innerJoin(
        salesDocuments,
        eq(salesDocumentLines.salesDocumentId, salesDocuments.id),
      )
      .innerJoin(items, eq(salesDocumentLines.itemId, items.id))
      .leftJoin(categories, eq(items.categoryId, categories.id))
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.isDeleted, false),
          eq(salesDocuments.status, 'finalized'),
          inArray(salesDocuments.documentType, [...REVENUE_SALES_TYPES]),
          eq(salesDocumentLines.isDeleted, false),
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
          query.category_id
            ? eq(items.categoryId, query.category_id)
            : undefined,
        ),
      )
      .groupBy(items.categoryId, categories.name);

    const purchaseAgg = await this.db
      .select({
        categoryId: items.categoryId,
        purchaseAmount: sql<string>`COALESCE(SUM(${purchaseDocumentLines.lineTotal}::numeric), 0)`,
      })
      .from(purchaseDocumentLines)
      .innerJoin(
        purchaseDocuments,
        eq(purchaseDocumentLines.purchaseDocumentId, purchaseDocuments.id),
      )
      .innerJoin(items, eq(purchaseDocumentLines.itemId, items.id))
      .where(
        and(
          eq(purchaseDocuments.businessId, businessId),
          eq(purchaseDocuments.isDeleted, false),
          eq(purchaseDocuments.status, 'finalized'),
          eq(purchaseDocuments.documentType, PURCHASE_BILL_TYPE),
          eq(purchaseDocumentLines.isDeleted, false),
          gte(purchaseDocuments.documentDate, range.from),
          lt(purchaseDocuments.documentDate, range.to),
          query.category_id
            ? eq(items.categoryId, query.category_id)
            : undefined,
        ),
      )
      .groupBy(items.categoryId);

    const purchaseMap = new Map(
      purchaseAgg.map((row) => [row.categoryId, row.purchaseAmount ?? '0']),
    );

    return saleAgg.map((row) => ({
      category: row.categoryName ?? 'Uncategorized',
      sale_amount: row.saleAmount ?? '0',
      purchase_amount: purchaseMap.get(row.categoryId) ?? '0',
    }));
  }

  async getSalePurchaseByItemCategory(
    businessId: string,
    query: ReportExtendedQuery,
  ) {
    const range = resolveRange(query);
    const mapped = await this.getCategoryAmountRows(businessId, query);
    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getStockSummaryByItemCategory(
    businessId: string,
    query: ReportExtendedQuery,
  ) {
    const range = resolveRange(query);
    const stockResult = await listStockItemAggregates(this.db, businessId, {
      godownId: query.godown_id,
      page: 1,
      limit: 10_000,
    });

    const categoryRows = await this.db
      .select({ id: categories.id, name: categories.name })
      .from(categories)
      .where(
        and(
          eq(categories.businessId, businessId),
          eq(categories.isDeleted, false),
        ),
      );
    const categoryNameMap = new Map(
      categoryRows.map((row) => [row.id, row.name]),
    );

    const grouped = new Map<
      string,
      { sale_amount: number; purchase_amount: number }
    >();
    for (const row of stockResult.rows) {
      const key = row.categoryId
        ? (categoryNameMap.get(row.categoryId) ?? 'Uncategorized')
        : 'Uncategorized';
      const existing = grouped.get(key) ?? {
        sale_amount: 0,
        purchase_amount: 0,
      };
      existing.purchase_amount += Number(row.stockValue);
      grouped.set(key, existing);
    }

    const amountRows = await this.getCategoryAmountRows(businessId, query);
    for (const row of amountRows) {
      const existing = grouped.get(row.category) ?? {
        sale_amount: 0,
        purchase_amount: 0,
      };
      existing.sale_amount += Number(row.sale_amount);
      grouped.set(row.category, existing);
    }

    const mapped: ReportCategoryAmountRow[] = [...grouped.entries()].map(
      ([category, values]) => ({
        category,
        sale_amount: String(values.sale_amount),
        purchase_amount: String(values.purchase_amount),
      }),
    );

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getItemCategoryWiseProfitLoss(
    businessId: string,
    query: ReportExtendedQuery,
  ) {
    const range = resolveRange(query);
    const rows = await this.getCategoryAmountRows(businessId, query);
    const mapped = rows.map((row) => ({
      category: row.category,
      sale_amount: row.sale_amount,
      purchase_amount: row.purchase_amount,
      profit: String(Number(row.sale_amount) - Number(row.purchase_amount)),
    }));
    const { rows: pageRows, total } = paginateSlice(
      mapped,
      query.page,
      query.limit,
    );
    return { total, payload: { period: toPeriodMeta(range), rows: pageRows } };
  }

  async getItemWiseDiscount(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportItemDiscountRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const grouped = await this.db
      .select({
        itemName: items.name,
        saleQty: sql<string>`COALESCE(SUM(${salesDocumentLines.quantity}::numeric), 0)`,
        discountAmount: sql<string>`COALESCE(SUM(${salesDocumentLines.discountAmount}::numeric), 0)`,
        grossAmount: sql<string>`COALESCE(SUM(${salesDocumentLines.quantity}::numeric * ${salesDocumentLines.unitPrice}::numeric), 0)`,
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
          gte(salesDocuments.documentDate, range.from),
          lt(salesDocuments.documentDate, range.to),
        ),
      )
      .groupBy(items.id, items.name)
      .having(
        sql`COALESCE(SUM(${salesDocumentLines.discountAmount}::numeric), 0) > 0`,
      );

    const mapped = grouped.map((row) => {
      const gross = Number(row.grossAmount ?? 0);
      const discount = Number(row.discountAmount ?? 0);
      const percent = gross > 0 ? (discount / gross) * 100 : 0;
      return {
        item_name: row.itemName ?? '',
        sale_qty: row.saleQty ?? '0',
        sale_amount: row.grossAmount ?? '0',
        discount_amount: row.discountAmount ?? '0',
        discount_percent: String(percent),
      };
    });

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getManufacturing(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportManufacturingRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const filters = [
      eq(jobWorkOrders.businessId, businessId),
      eq(jobWorkOrders.isDeleted, false),
      gte(jobWorkOrders.orderDate, range.from),
      lt(jobWorkOrders.orderDate, range.to),
    ];
    if (query.status) {
      filters.push(eq(jobWorkOrders.status, query.status as never));
    }

    const rows = await this.db
      .select({
        date: jobWorkOrders.orderDate,
        refNo: jobWorkOrders.jobNumber,
        itemName: jobWorkOrders.finishedGoodName,
        quantity: jobWorkOrders.finishedGoodQuantity,
        cost: jobWorkOrders.grandTotal,
      })
      .from(jobWorkOrders)
      .where(and(...filters))
      .orderBy(desc(jobWorkOrders.orderDate));

    const mapped = rows.map((row) => ({
      date: row.date.toISOString(),
      ref_no: row.refNo ?? '',
      item_name: row.itemName,
      quantity: row.quantity ?? '0',
      cost: row.cost ?? '0',
    }));

    const { rows: pageRows, total } = paginateSlice(
      mapped,
      query.page,
      query.limit,
    );
    return { total, payload: { period: toPeriodMeta(range), rows: pageRows } };
  }

  async getConsumption(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportConsumptionRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const rows = await this.db
      .select({
        date: jobWorkOrders.orderDate,
        refNo: jobWorkOrders.jobNumber,
        itemName: items.name,
        quantity: jobWorkRawMaterialLines.quantity,
        value: jobWorkRawMaterialLines.lineTotal,
      })
      .from(jobWorkRawMaterialLines)
      .innerJoin(
        jobWorkOrders,
        eq(jobWorkRawMaterialLines.jobWorkOrderId, jobWorkOrders.id),
      )
      .innerJoin(items, eq(jobWorkRawMaterialLines.itemId, items.id))
      .where(
        and(
          eq(jobWorkRawMaterialLines.businessId, businessId),
          eq(jobWorkRawMaterialLines.isDeleted, false),
          eq(jobWorkOrders.isDeleted, false),
          gte(jobWorkOrders.orderDate, range.from),
          lt(jobWorkOrders.orderDate, range.to),
        ),
      )
      .orderBy(desc(jobWorkOrders.orderDate));

    const mapped = rows.map((row) => ({
      date: row.date.toISOString(),
      ref_no: row.refNo ?? '',
      item_name: row.itemName ?? '',
      quantity: row.quantity ?? '0',
      value: row.value ?? '0',
    }));

    const { rows: pageRows, total } = paginateSlice(
      mapped,
      query.page,
      query.limit,
    );
    return { total, payload: { period: toPeriodMeta(range), rows: pageRows } };
  }

  async getStockTransfer(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportStockTransferRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const transferRows = await this.db
      .select({
        date: inventoryMovements.createdAt,
        refId: inventoryMovements.referenceId,
        itemName: items.name,
        godownName: godowns.name,
        quantity: inventoryMovements.quantityDelta,
        referenceType: inventoryMovements.referenceType,
        movementType: inventoryMovements.movementType,
      })
      .from(inventoryMovements)
      .innerJoin(items, eq(inventoryMovements.itemId, items.id))
      .innerJoin(godowns, eq(inventoryMovements.godownId, godowns.id))
      .where(
        and(
          eq(inventoryMovements.businessId, businessId),
          gte(inventoryMovements.createdAt, range.from),
          lt(inventoryMovements.createdAt, range.to),
          or(
            eq(inventoryMovements.referenceType, 'stock_transfer'),
            and(
              eq(inventoryMovements.movementType, 'adjustment'),
              sql`${inventoryMovements.referenceId} IS NOT NULL`,
            ),
          ),
        ),
      )
      .orderBy(desc(inventoryMovements.createdAt));

    const groupedByRef = new Map<string, typeof transferRows>();
    for (const row of transferRows) {
      const key = row.refId ?? row.date.toISOString();
      const list = groupedByRef.get(key) ?? [];
      list.push(row);
      groupedByRef.set(key, list);
    }

    const mapped: ReportStockTransferRow[] = [];
    for (const [refId, movements] of groupedByRef) {
      const outMovement = movements.find((m) => Number(m.quantity) < 0);
      const inMovement = movements.find((m) => Number(m.quantity) > 0);
      const primary = outMovement ?? inMovement ?? movements[0];
      if (!primary) continue;

      mapped.push({
        date: primary.date.toISOString(),
        ref_no: refId,
        from_godown: outMovement?.godownName ?? '',
        to_godown: inMovement?.godownName ?? '',
        item_name: primary.itemName ?? '',
        quantity: String(Math.abs(Number(primary.quantity ?? 0))),
      });
    }

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }
}
