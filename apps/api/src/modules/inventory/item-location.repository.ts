import { and, asc, count, desc, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { itemLocations } from '../../db/schema/inventory/tables';
import { toItemLocationRecord } from './item-location.mapper';
import type {
  ItemLocationInsertValues,
  ItemLocationRecord,
  ItemLocationRow,
  ItemLocationUpdateValues,
  ListItemLocationsParams,
} from './item-location.types';

export class ItemLocationRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListItemLocationsParams): Promise<{
    rows: ItemLocationRecord[];
    total: number;
  }> {
    const filters = [
      eq(itemLocations.businessId, params.businessId),
      eq(itemLocations.isDeleted, false),
    ];

    if (params.itemId) {
      filters.push(eq(itemLocations.itemId, params.itemId));
    }

    if (params.godownId) {
      filters.push(eq(itemLocations.godownId, params.godownId));
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(itemLocations)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);
    const orderBy =
      params.order === 'desc'
        ? desc(itemLocations.createdAt)
        : asc(itemLocations.createdAt);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: itemLocations.id,
        itemId: itemLocations.itemId,
        godownId: itemLocations.godownId,
        rack: itemLocations.rack,
        shelf: itemLocations.shelf,
        photoUrl: itemLocations.photoUrl,
        photoTakenAt: itemLocations.photoTakenAt,
        createdAt: itemLocations.createdAt,
        updatedAt: itemLocations.updatedAt,
      })
      .from(itemLocations)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toItemLocationRecord(row as ItemLocationRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    locationId: string,
  ): Promise<ItemLocationRecord | null> {
    const [row] = await this.db
      .select({
        id: itemLocations.id,
        itemId: itemLocations.itemId,
        godownId: itemLocations.godownId,
        rack: itemLocations.rack,
        shelf: itemLocations.shelf,
        photoUrl: itemLocations.photoUrl,
        photoTakenAt: itemLocations.photoTakenAt,
        createdAt: itemLocations.createdAt,
        updatedAt: itemLocations.updatedAt,
      })
      .from(itemLocations)
      .where(
        and(
          eq(itemLocations.id, locationId),
          eq(itemLocations.businessId, businessId),
          eq(itemLocations.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toItemLocationRecord(row as ItemLocationRow) : null;
  }

  async create(values: ItemLocationInsertValues): Promise<ItemLocationRecord> {
    const [row] = await this.db
      .insert(itemLocations)
      .values({
        businessId: values.businessId,
        itemId: values.itemId,
        godownId: values.godownId,
        rack: values.rack ?? null,
        shelf: values.shelf ?? null,
        photoUrl: values.photoUrl ?? null,
        photoTakenAt: values.photoTakenAt ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: itemLocations.id,
        itemId: itemLocations.itemId,
        godownId: itemLocations.godownId,
        rack: itemLocations.rack,
        shelf: itemLocations.shelf,
        photoUrl: itemLocations.photoUrl,
        photoTakenAt: itemLocations.photoTakenAt,
        createdAt: itemLocations.createdAt,
        updatedAt: itemLocations.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create item location');
    }

    return toItemLocationRecord(row as ItemLocationRow);
  }

  async update(
    businessId: string,
    locationId: string,
    values: ItemLocationUpdateValues,
  ): Promise<ItemLocationRecord | null> {
    const [row] = await this.db
      .update(itemLocations)
      .set({
        ...(values.godownId !== undefined ? { godownId: values.godownId } : {}),
        ...(values.rack !== undefined ? { rack: values.rack } : {}),
        ...(values.shelf !== undefined ? { shelf: values.shelf } : {}),
        ...(values.photoUrl !== undefined ? { photoUrl: values.photoUrl } : {}),
        ...(values.photoTakenAt !== undefined
          ? { photoTakenAt: values.photoTakenAt }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${itemLocations.syncVersion} + 1`,
      })
      .where(
        and(
          eq(itemLocations.id, locationId),
          eq(itemLocations.businessId, businessId),
          eq(itemLocations.isDeleted, false),
        ),
      )
      .returning({
        id: itemLocations.id,
        itemId: itemLocations.itemId,
        godownId: itemLocations.godownId,
        rack: itemLocations.rack,
        shelf: itemLocations.shelf,
        photoUrl: itemLocations.photoUrl,
        photoTakenAt: itemLocations.photoTakenAt,
        createdAt: itemLocations.createdAt,
        updatedAt: itemLocations.updatedAt,
      });

    return row ? toItemLocationRecord(row as ItemLocationRow) : null;
  }

  async softDelete(
    businessId: string,
    locationId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(itemLocations)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${itemLocations.syncVersion} + 1`,
      })
      .where(
        and(
          eq(itemLocations.id, locationId),
          eq(itemLocations.businessId, businessId),
          eq(itemLocations.isDeleted, false),
        ),
      )
      .returning({ id: itemLocations.id });

    return Boolean(row);
  }
}
