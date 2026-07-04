import { and, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { godowns, items, stockLevels } from '../../db/schema/inventory/tables';

export type StockItemAggregate = {
  itemId: string;
  itemName: string;
  categoryId: string | null;
  totalQty: string;
  reorderLevel: string | null;
  averageCost: string;
  stockValue: string;
};

function stockLevelFilters(businessId: string, godownId?: string) {
  const filters = [
    eq(stockLevels.businessId, businessId),
    eq(stockLevels.isDeleted, false),
    eq(items.isDeleted, false),
    eq(godowns.isDeleted, false),
  ];

  if (godownId) {
    filters.push(eq(stockLevels.godownId, godownId));
  }

  return and(...filters);
}

export function buildItemStockAggSubquery(
  db: Database,
  businessId: string,
  godownId?: string,
) {
  return db
    .select({
      itemId: items.id,
      itemName: items.name,
      categoryId: items.categoryId,
      totalQty: sql<string>`COALESCE(SUM(${stockLevels.quantity}::numeric), 0)`.as(
        'total_qty',
      ),
      reorderLevel:
        sql<string>`MAX(COALESCE(${stockLevels.reorderLevel}, ${items.reorderLevel}))`.as(
          'reorder_level',
        ),
      averageCost:
        sql<string>`CASE WHEN SUM(${stockLevels.quantity}::numeric) > 0
          THEN SUM(${stockLevels.quantity}::numeric * ${stockLevels.averageCost}::numeric)
            / SUM(${stockLevels.quantity}::numeric)
          ELSE 0 END`.as('average_cost'),
      stockValue:
        sql<string>`COALESCE(SUM(${stockLevels.quantity}::numeric * ${stockLevels.averageCost}::numeric), 0)`.as(
          'stock_value',
        ),
    })
    .from(stockLevels)
    .innerJoin(items, eq(stockLevels.itemId, items.id))
    .innerJoin(godowns, eq(stockLevels.godownId, godowns.id))
    .where(stockLevelFilters(businessId, godownId))
    .groupBy(items.id, items.name, items.categoryId)
    .as('item_agg');
}

export async function getTotalStockValue(
  db: Database,
  businessId: string,
  godownId?: string,
): Promise<string> {
  const [valueRow] = await db
    .select({
      total: sql<string>`COALESCE(SUM(
        ${stockLevels.quantity}::numeric * ${stockLevels.averageCost}::numeric
      ), 0)`,
    })
    .from(stockLevels)
    .innerJoin(items, eq(stockLevels.itemId, items.id))
    .innerJoin(godowns, eq(stockLevels.godownId, godowns.id))
    .where(stockLevelFilters(businessId, godownId));

  return valueRow?.total ?? '0';
}

export async function listStockItemAggregates(
  db: Database,
  businessId: string,
  options: {
    godownId?: string;
    itemId?: string;
    q?: string;
    inStockOnly?: boolean;
    lowStockOnly?: boolean;
    page?: number;
    limit?: number;
  } = {},
): Promise<{ rows: StockItemAggregate[]; total: number }> {
  const page = options.page ?? 1;
  const limit = options.limit ?? 50;
  const itemAgg = buildItemStockAggSubquery(db, businessId, options.godownId);

  const conditions = [];
  if (options.itemId) {
    conditions.push(sql`${itemAgg.itemId} = ${options.itemId}`);
  }
  if (options.q) {
    conditions.push(sql`${itemAgg.itemName} ILIKE ${`%${options.q}%`}`);
  }
  if (options.inStockOnly) {
    conditions.push(sql`${itemAgg.totalQty}::numeric > 0`);
  }
  if (options.lowStockOnly) {
    conditions.push(
      sql`${itemAgg.totalQty}::numeric <= ${itemAgg.reorderLevel}::numeric
        AND ${itemAgg.reorderLevel} IS NOT NULL`,
    );
  }

  const whereClause =
    conditions.length > 0 ? sql.join(conditions, sql` AND `) : undefined;

  const countQuery = db
    .select({ total: sql<number>`COUNT(*)::int` })
    .from(itemAgg);
  const [countRow] = whereClause
    ? await countQuery.where(whereClause)
    : await countQuery;
  const total = Number(countRow?.total ?? 0);

  const offset = (page - 1) * limit;
  const rowsQuery = db
    .select({
      itemId: itemAgg.itemId,
      itemName: itemAgg.itemName,
      categoryId: itemAgg.categoryId,
      totalQty: itemAgg.totalQty,
      reorderLevel: itemAgg.reorderLevel,
      averageCost: itemAgg.averageCost,
      stockValue: itemAgg.stockValue,
    })
    .from(itemAgg);

  const rows = whereClause
    ? await rowsQuery
        .where(whereClause)
        .orderBy(itemAgg.itemName)
        .limit(limit)
        .offset(offset)
    : await rowsQuery.orderBy(itemAgg.itemName).limit(limit).offset(offset);

  return {
    rows: rows.map((row) => ({
      itemId: row.itemId,
      itemName: row.itemName,
      categoryId: row.categoryId,
      totalQty: row.totalQty ?? '0',
      reorderLevel: row.reorderLevel,
      averageCost: row.averageCost ?? '0',
      stockValue: row.stockValue ?? '0',
    })),
    total,
  };
}

export async function countLowAndNegativeStock(
  db: Database,
  businessId: string,
  godownId?: string,
): Promise<{ lowStockCount: number; negativeStockCount: number }> {
  const itemAgg = buildItemStockAggSubquery(db, businessId, godownId);

  const [counts] = await db
    .select({
      lowStockCount: sql<number>`COUNT(*) FILTER (
        WHERE ${itemAgg.totalQty}::numeric <= ${itemAgg.reorderLevel}::numeric
          AND ${itemAgg.reorderLevel} IS NOT NULL
      )::int`,
      negativeStockCount: sql<number>`COUNT(*) FILTER (
        WHERE ${itemAgg.totalQty}::numeric < 0
      )::int`,
    })
    .from(itemAgg);

  return {
    lowStockCount: Number(counts?.lowStockCount ?? 0),
    negativeStockCount: Number(counts?.negativeStockCount ?? 0),
  };
}
