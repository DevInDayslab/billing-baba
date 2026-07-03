import { and, count, desc, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { itemPriceHistory, items } from '../../db/schema/inventory/tables';
import { toPriceHistoryRecord } from './price-history.mapper';
import type {
  ListPriceHistoryParams,
  PriceHistoryRecord,
  PriceHistoryRow,
} from './price-history.types';

export class PriceHistoryRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListPriceHistoryParams): Promise<{
    rows: PriceHistoryRecord[];
    total: number;
  }> {
    const filters = [
      eq(itemPriceHistory.businessId, params.businessId),
      eq(items.isDeleted, false),
    ];

    if (params.itemId) {
      filters.push(eq(itemPriceHistory.itemId, params.itemId));
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(itemPriceHistory)
      .innerJoin(items, eq(itemPriceHistory.itemId, items.id))
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: itemPriceHistory.id,
        itemId: itemPriceHistory.itemId,
        itemName: items.name,
        price: itemPriceHistory.price,
        pricingTier: itemPriceHistory.pricingTier,
        changedBy: itemPriceHistory.changedBy,
        createdAt: itemPriceHistory.createdAt,
      })
      .from(itemPriceHistory)
      .innerJoin(items, eq(itemPriceHistory.itemId, items.id))
      .where(whereClause)
      .orderBy(desc(itemPriceHistory.createdAt))
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toPriceHistoryRecord(row as PriceHistoryRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    historyId: string,
  ): Promise<PriceHistoryRecord | null> {
    const [row] = await this.db
      .select({
        id: itemPriceHistory.id,
        itemId: itemPriceHistory.itemId,
        itemName: items.name,
        price: itemPriceHistory.price,
        pricingTier: itemPriceHistory.pricingTier,
        changedBy: itemPriceHistory.changedBy,
        createdAt: itemPriceHistory.createdAt,
      })
      .from(itemPriceHistory)
      .innerJoin(items, eq(itemPriceHistory.itemId, items.id))
      .where(
        and(
          eq(itemPriceHistory.id, historyId),
          eq(itemPriceHistory.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toPriceHistoryRecord(row as PriceHistoryRow) : null;
  }
}
