import { and, count, desc, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { itemLocationHistory } from '../../db/schema/inventory/tables';
import { toItemLocationHistoryRecord } from './item-location-history.mapper';
import type {
  InsertItemLocationHistoryInput,
  ItemLocationHistoryRecord,
  ListItemLocationHistoryParams,
} from './item-location-history.types';

export class ItemLocationHistoryRepository {
  constructor(private readonly db: Database) {}

  async insert(input: InsertItemLocationHistoryInput): Promise<void> {
    await this.db.insert(itemLocationHistory).values({
      businessId: input.businessId,
      itemLocationId: input.itemLocationId,
      itemId: input.itemId,
      rack: input.rack ?? null,
      shelf: input.shelf ?? null,
      photoUrl: input.photoUrl ?? null,
      photoMediaAssetId: input.photoMediaAssetId ?? null,
      employeeLabel: input.employeeLabel ?? null,
      changedBy: input.changedBy ?? null,
    });
  }

  async listByLocation(
    params: ListItemLocationHistoryParams,
  ): Promise<{ rows: ItemLocationHistoryRecord[]; total: number }> {
    const whereClause = and(
      eq(itemLocationHistory.businessId, params.businessId),
      eq(itemLocationHistory.itemLocationId, params.itemLocationId),
    );

    const countResult = await this.db
      .select({ total: count() })
      .from(itemLocationHistory)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: itemLocationHistory.id,
        itemLocationId: itemLocationHistory.itemLocationId,
        itemId: itemLocationHistory.itemId,
        rack: itemLocationHistory.rack,
        shelf: itemLocationHistory.shelf,
        photoUrl: itemLocationHistory.photoUrl,
        employeeLabel: itemLocationHistory.employeeLabel,
        changedBy: itemLocationHistory.changedBy,
        createdAt: itemLocationHistory.createdAt,
      })
      .from(itemLocationHistory)
      .where(whereClause)
      .orderBy(desc(itemLocationHistory.createdAt))
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toItemLocationHistoryRecord(row)),
      total,
    };
  }
}
