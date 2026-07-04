import { and, asc, count, desc, eq, ilike, ne, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  godowns,
  itemLocations,
  stockLevels,
} from '../../db/schema/inventory/tables';
import { toGodownRecord } from './godown.mapper';
import type {
  GodownInsertValues,
  GodownRecord,
  GodownRow,
  GodownUpdateValues,
  ListGodownsParams,
} from './godown.types';

export class GodownRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListGodownsParams): Promise<{
    rows: GodownRecord[];
    total: number;
  }> {
    const filters = [
      eq(godowns.businessId, params.businessId),
      eq(godowns.isDeleted, false),
    ];

    if (params.q) {
      filters.push(ilike(godowns.name, `%${params.q}%`));
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(godowns)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at' ? godowns.createdAt : godowns.name;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const stockItemCountSubquery = this.db
      .select({ total: count() })
      .from(stockLevels)
      .where(
        and(
          eq(stockLevels.godownId, godowns.id),
          eq(stockLevels.businessId, params.businessId),
          eq(stockLevels.isDeleted, false),
          sql`${stockLevels.quantity} > 0`,
        ),
      );

    const rows = await this.db
      .select({
        id: godowns.id,
        name: godowns.name,
        address: godowns.address,
        isDefault: godowns.isDefault,
        stockItemCount: sql<number>`(${stockItemCountSubquery})`.mapWith(
          Number,
        ),
        createdAt: godowns.createdAt,
        updatedAt: godowns.updatedAt,
      })
      .from(godowns)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toGodownRecord(row as GodownRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    godownId: string,
  ): Promise<GodownRecord | null> {
    const stockItemCountSubquery = this.db
      .select({ total: count() })
      .from(stockLevels)
      .where(
        and(
          eq(stockLevels.godownId, godowns.id),
          eq(stockLevels.businessId, businessId),
          eq(stockLevels.isDeleted, false),
          sql`${stockLevels.quantity} > 0`,
        ),
      );

    const [row] = await this.db
      .select({
        id: godowns.id,
        name: godowns.name,
        address: godowns.address,
        isDefault: godowns.isDefault,
        stockItemCount: sql<number>`(${stockItemCountSubquery})`.mapWith(
          Number,
        ),
        createdAt: godowns.createdAt,
        updatedAt: godowns.updatedAt,
      })
      .from(godowns)
      .where(
        and(
          eq(godowns.id, godownId),
          eq(godowns.businessId, businessId),
          eq(godowns.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toGodownRecord(row as GodownRow) : null;
  }

  async findRowById(
    businessId: string,
    godownId: string,
  ): Promise<GodownRow | null> {
    const [row] = await this.db
      .select({
        id: godowns.id,
        name: godowns.name,
        address: godowns.address,
        isDefault: godowns.isDefault,
        createdAt: godowns.createdAt,
        updatedAt: godowns.updatedAt,
      })
      .from(godowns)
      .where(
        and(
          eq(godowns.id, godownId),
          eq(godowns.businessId, businessId),
          eq(godowns.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? (row as GodownRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeGodownId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(godowns.businessId, businessId),
      eq(godowns.isDeleted, false),
      sql`lower(${godowns.name}) = lower(${name})`,
    ];

    if (excludeGodownId) {
      conditions.push(ne(godowns.id, excludeGodownId));
    }

    const [row] = await this.db
      .select({ id: godowns.id })
      .from(godowns)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async create(values: GodownInsertValues): Promise<GodownRecord> {
    const [row] = await this.db
      .insert(godowns)
      .values({
        businessId: values.businessId,
        name: values.name,
        address: values.address ?? null,
        isDefault: values.isDefault ?? false,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: godowns.id,
        name: godowns.name,
        address: godowns.address,
        isDefault: godowns.isDefault,
        createdAt: godowns.createdAt,
        updatedAt: godowns.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create godown');
    }

    return toGodownRecord(row as GodownRow);
  }

  async update(
    businessId: string,
    godownId: string,
    values: GodownUpdateValues,
  ): Promise<GodownRecord | null> {
    const [row] = await this.db
      .update(godowns)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.address !== undefined ? { address: values.address } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${godowns.syncVersion} + 1`,
      })
      .where(
        and(
          eq(godowns.id, godownId),
          eq(godowns.businessId, businessId),
          eq(godowns.isDeleted, false),
        ),
      )
      .returning({
        id: godowns.id,
        name: godowns.name,
        address: godowns.address,
        isDefault: godowns.isDefault,
        createdAt: godowns.createdAt,
        updatedAt: godowns.updatedAt,
      });

    return row ? toGodownRecord(row as GodownRow) : null;
  }

  async softDelete(
    businessId: string,
    godownId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(godowns)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${godowns.syncVersion} + 1`,
      })
      .where(
        and(
          eq(godowns.id, godownId),
          eq(godowns.businessId, businessId),
          eq(godowns.isDeleted, false),
        ),
      )
      .returning({ id: godowns.id });

    return Boolean(row);
  }

  async countNonZeroStockLevels(
    businessId: string,
    godownId: string,
  ): Promise<number> {
    const [result] = await this.db
      .select({ total: count() })
      .from(stockLevels)
      .where(
        and(
          eq(stockLevels.businessId, businessId),
          eq(stockLevels.godownId, godownId),
          eq(stockLevels.isDeleted, false),
          sql`${stockLevels.quantity} <> 0`,
        ),
      );

    return Number(result?.total ?? 0);
  }

  async countActiveItemLocations(
    businessId: string,
    godownId: string,
  ): Promise<number> {
    const [result] = await this.db
      .select({ total: count() })
      .from(itemLocations)
      .where(
        and(
          eq(itemLocations.businessId, businessId),
          eq(itemLocations.godownId, godownId),
          eq(itemLocations.isDeleted, false),
        ),
      );

    return Number(result?.total ?? 0);
  }
}
