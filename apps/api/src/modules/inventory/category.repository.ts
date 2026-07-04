import { and, asc, count, desc, eq, ilike, ne, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { categories, items } from '../../db/schema/inventory/tables';
import { toCategoryRecord } from './category.mapper';
import type {
  CategoryInsertValues,
  CategoryRecord,
  CategoryRow,
  CategoryUpdateValues,
  ListCategoriesParams,
} from './category.types';

export class CategoryRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListCategoriesParams): Promise<{
    rows: CategoryRecord[];
    total: number;
  }> {
    const filters = [
      eq(categories.businessId, params.businessId),
      eq(categories.isDeleted, false),
    ];

    if (params.q) {
      filters.push(ilike(categories.name, `%${params.q}%`));
    }

    const whereClause = and(...filters);

    const countResult = await this.db
      .select({ total: count() })
      .from(categories)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at' ? categories.createdAt : categories.name;

    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);

    const offset = (params.page - 1) * params.limit;

    const itemCountSubquery = this.db
      .select({ total: count() })
      .from(items)
      .where(
        and(
          eq(items.categoryId, categories.id),
          eq(items.businessId, params.businessId),
          eq(items.isDeleted, false),
        ),
      );

    const rows = await this.db
      .select({
        id: categories.id,
        name: categories.name,
        itemCount: sql<number>`(${itemCountSubquery})`.mapWith(Number),
        createdAt: categories.createdAt,
        updatedAt: categories.updatedAt,
      })
      .from(categories)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toCategoryRecord(row as CategoryRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    categoryId: string,
  ): Promise<CategoryRecord | null> {
    const itemCountSubquery = this.db
      .select({ total: count() })
      .from(items)
      .where(
        and(
          eq(items.categoryId, categories.id),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      );

    const [row] = await this.db
      .select({
        id: categories.id,
        name: categories.name,
        itemCount: sql<number>`(${itemCountSubquery})`.mapWith(Number),
        createdAt: categories.createdAt,
        updatedAt: categories.updatedAt,
      })
      .from(categories)
      .where(
        and(
          eq(categories.id, categoryId),
          eq(categories.businessId, businessId),
          eq(categories.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toCategoryRecord(row as CategoryRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeCategoryId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(categories.businessId, businessId),
      eq(categories.isDeleted, false),
      sql`lower(${categories.name}) = lower(${name})`,
    ];

    if (excludeCategoryId) {
      conditions.push(ne(categories.id, excludeCategoryId));
    }

    const [row] = await this.db
      .select({ id: categories.id })
      .from(categories)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async create(values: CategoryInsertValues): Promise<CategoryRecord> {
    const [row] = await this.db
      .insert(categories)
      .values({
        businessId: values.businessId,
        name: values.name,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: categories.id,
        name: categories.name,
        createdAt: categories.createdAt,
        updatedAt: categories.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create category');
    }

    return toCategoryRecord({
      ...row,
      itemCount: 0,
    });
  }

  async update(
    businessId: string,
    categoryId: string,
    values: CategoryUpdateValues,
  ): Promise<CategoryRecord | null> {
    const [row] = await this.db
      .update(categories)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${categories.syncVersion} + 1`,
      })
      .where(
        and(
          eq(categories.id, categoryId),
          eq(categories.businessId, businessId),
          eq(categories.isDeleted, false),
        ),
      )
      .returning({
        id: categories.id,
        name: categories.name,
        createdAt: categories.createdAt,
        updatedAt: categories.updatedAt,
      });

    if (!row) {
      return null;
    }

    const itemCount = await this.countActiveItems(businessId, categoryId);

    return toCategoryRecord({
      ...row,
      itemCount,
    });
  }

  async softDelete(
    businessId: string,
    categoryId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(categories)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${categories.syncVersion} + 1`,
      })
      .where(
        and(
          eq(categories.id, categoryId),
          eq(categories.businessId, businessId),
          eq(categories.isDeleted, false),
        ),
      )
      .returning({ id: categories.id });

    return Boolean(row);
  }

  async countActiveItems(
    businessId: string,
    categoryId: string,
  ): Promise<number> {
    const [result] = await this.db
      .select({ total: count() })
      .from(items)
      .where(
        and(
          eq(items.businessId, businessId),
          eq(items.categoryId, categoryId),
          eq(items.isDeleted, false),
        ),
      );

    return Number(result?.total ?? 0);
  }
}
