import { and, asc, count, desc, eq, ilike, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { godowns, items, stockLevels } from '../../db/schema/inventory/tables';
import { toStockLevelRecord } from './stock-level.mapper';
import type {
  ListStockLevelsParams,
  StockLevelRecord,
  StockLevelRow,
} from './stock-level.types';

export class StockLevelRepository {
  constructor(private readonly db: Database) {}

  private buildFilters(params: ListStockLevelsParams) {
    const filters = [
      eq(stockLevels.businessId, params.businessId),
      eq(stockLevels.isDeleted, false),
      eq(items.isDeleted, false),
      eq(godowns.isDeleted, false),
    ];

    if (params.itemId) {
      filters.push(eq(stockLevels.itemId, params.itemId));
    }

    if (params.godownId) {
      filters.push(eq(stockLevels.godownId, params.godownId));
    }

    if (params.q) {
      filters.push(ilike(items.name, `%${params.q}%`));
    }

    if (params.lowStock) {
      filters.push(
        sql`(
          ${stockLevels.quantity} <= COALESCE(${stockLevels.reorderLevel}, ${items.reorderLevel})
          AND COALESCE(${stockLevels.reorderLevel}, ${items.reorderLevel}) IS NOT NULL
        )`,
      );
    }

    return and(...filters);
  }

  private selectShape() {
    return {
      id: stockLevels.id,
      itemId: stockLevels.itemId,
      itemName: items.name,
      godownId: stockLevels.godownId,
      godownName: godowns.name,
      quantity: stockLevels.quantity,
      averageCost: stockLevels.averageCost,
      reorderLevel: stockLevels.reorderLevel,
      itemReorderLevel: items.reorderLevel,
      createdAt: stockLevels.createdAt,
      updatedAt: stockLevels.updatedAt,
    };
  }

  async list(params: ListStockLevelsParams): Promise<{
    rows: StockLevelRecord[];
    total: number;
  }> {
    const whereClause = this.buildFilters(params);

    const countResult = await this.db
      .select({ total: count() })
      .from(stockLevels)
      .innerJoin(items, eq(stockLevels.itemId, items.id))
      .innerJoin(godowns, eq(stockLevels.godownId, godowns.id))
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? stockLevels.createdAt
        : stockLevels.quantity;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select(this.selectShape())
      .from(stockLevels)
      .innerJoin(items, eq(stockLevels.itemId, items.id))
      .innerJoin(godowns, eq(stockLevels.godownId, godowns.id))
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toStockLevelRecord(row as StockLevelRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    stockLevelId: string,
  ): Promise<StockLevelRecord | null> {
    const [row] = await this.db
      .select(this.selectShape())
      .from(stockLevels)
      .innerJoin(items, eq(stockLevels.itemId, items.id))
      .innerJoin(godowns, eq(stockLevels.godownId, godowns.id))
      .where(
        and(
          eq(stockLevels.id, stockLevelId),
          eq(stockLevels.businessId, businessId),
          eq(stockLevels.isDeleted, false),
          eq(items.isDeleted, false),
          eq(godowns.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toStockLevelRecord(row as StockLevelRow) : null;
  }
}
