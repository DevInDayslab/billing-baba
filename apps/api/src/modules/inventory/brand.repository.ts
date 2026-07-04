import { and, asc, count, desc, eq, ilike, ne, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { brands, items } from '../../db/schema/inventory/tables';
import { toBrandRecord } from './brand.mapper';
import type {
  BrandInsertValues,
  BrandRecord,
  BrandRow,
  BrandUpdateValues,
  ListBrandsParams,
} from './brand.types';

export class BrandRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListBrandsParams): Promise<{
    rows: BrandRecord[];
    total: number;
  }> {
    const filters = [
      eq(brands.businessId, params.businessId),
      eq(brands.isDeleted, false),
    ];

    if (params.q) {
      filters.push(ilike(brands.name, `%${params.q}%`));
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(brands)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at' ? brands.createdAt : brands.name;

    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);

    const offset = (params.page - 1) * params.limit;

    const itemCountSubquery = this.db
      .select({ total: count() })
      .from(items)
      .where(
        and(
          eq(items.brandId, brands.id),
          eq(items.businessId, params.businessId),
          eq(items.isDeleted, false),
        ),
      );

    const rows = await this.db
      .select({
        id: brands.id,
        name: brands.name,
        itemCount: sql<number>`(${itemCountSubquery})`.mapWith(Number),
        createdAt: brands.createdAt,
        updatedAt: brands.updatedAt,
      })
      .from(brands)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toBrandRecord(row as BrandRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    brandId: string,
  ): Promise<BrandRecord | null> {
    const itemCountSubquery = this.db
      .select({ total: count() })
      .from(items)
      .where(
        and(
          eq(items.brandId, brands.id),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      );

    const [row] = await this.db
      .select({
        id: brands.id,
        name: brands.name,
        itemCount: sql<number>`(${itemCountSubquery})`.mapWith(Number),
        createdAt: brands.createdAt,
        updatedAt: brands.updatedAt,
      })
      .from(brands)
      .where(
        and(
          eq(brands.id, brandId),
          eq(brands.businessId, businessId),
          eq(brands.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toBrandRecord(row as BrandRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeBrandId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(brands.businessId, businessId),
      eq(brands.isDeleted, false),
      sql`lower(${brands.name}) = lower(${name})`,
    ];

    if (excludeBrandId) {
      conditions.push(ne(brands.id, excludeBrandId));
    }

    const [row] = await this.db
      .select({ id: brands.id })
      .from(brands)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async create(values: BrandInsertValues): Promise<BrandRecord> {
    const [row] = await this.db
      .insert(brands)
      .values({
        businessId: values.businessId,
        name: values.name,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: brands.id,
        name: brands.name,
        createdAt: brands.createdAt,
        updatedAt: brands.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create brand');
    }

    return toBrandRecord({
      ...row,
      itemCount: 0,
    });
  }

  async update(
    businessId: string,
    brandId: string,
    values: BrandUpdateValues,
  ): Promise<BrandRecord | null> {
    const [row] = await this.db
      .update(brands)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${brands.syncVersion} + 1`,
      })
      .where(
        and(
          eq(brands.id, brandId),
          eq(brands.businessId, businessId),
          eq(brands.isDeleted, false),
        ),
      )
      .returning({
        id: brands.id,
        name: brands.name,
        createdAt: brands.createdAt,
        updatedAt: brands.updatedAt,
      });

    if (!row) {
      return null;
    }

    const itemCount = await this.countActiveItems(businessId, brandId);

    return toBrandRecord({
      ...row,
      itemCount,
    });
  }

  async softDelete(
    businessId: string,
    brandId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(brands)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${brands.syncVersion} + 1`,
      })
      .where(
        and(
          eq(brands.id, brandId),
          eq(brands.businessId, businessId),
          eq(brands.isDeleted, false),
        ),
      )
      .returning({ id: brands.id });

    return Boolean(row);
  }

  async countActiveItems(businessId: string, brandId: string): Promise<number> {
    const [result] = await this.db
      .select({ total: count() })
      .from(items)
      .where(
        and(
          eq(items.businessId, businessId),
          eq(items.brandId, brandId),
          eq(items.isDeleted, false),
        ),
      );

    return Number(result?.total ?? 0);
  }
}
