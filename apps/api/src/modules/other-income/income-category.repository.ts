import { and, asc, count, desc, eq, ilike, ne, sql, sum } from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  incomeCategories,
  otherIncomes,
} from '../../db/schema/other-income/tables';
import { toIncomeCategoryRecord } from './income-category.mapper';
import type {
  IncomeCategoryInsertValues,
  IncomeCategoryRecord,
  IncomeCategoryRow,
  IncomeCategoryUpdateValues,
  ListIncomeCategoriesParams,
} from './income-category.types';

export class IncomeCategoryRepository {
  constructor(private readonly db: Database) {}

  private incomeCountSubquery() {
    return this.db
      .select({ total: count() })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.categoryId, incomeCategories.id),
          eq(otherIncomes.businessId, incomeCategories.businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );
  }

  private incomeTotalSubquery() {
    return this.db
      .select({ total: sum(otherIncomes.amount) })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.categoryId, incomeCategories.id),
          eq(otherIncomes.businessId, incomeCategories.businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );
  }

  async list(params: ListIncomeCategoriesParams): Promise<{
    rows: IncomeCategoryRecord[];
    total: number;
  }> {
    const filters = [
      eq(incomeCategories.businessId, params.businessId),
      eq(incomeCategories.isDeleted, false),
    ];

    if (params.q) {
      filters.push(ilike(incomeCategories.name, `%${params.q}%`));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(incomeCategories)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? incomeCategories.createdAt
        : incomeCategories.name;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: incomeCategories.id,
        name: incomeCategories.name,
        categoryType: incomeCategories.categoryType,
        isSystem: incomeCategories.isSystem,
        incomeCount: sql<number>`(${this.incomeCountSubquery()})`.mapWith(
          Number,
        ),
        totalAmount: sql<string>`coalesce((${this.incomeTotalSubquery()}), '0')`,
        createdAt: incomeCategories.createdAt,
        updatedAt: incomeCategories.updatedAt,
      })
      .from(incomeCategories)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toIncomeCategoryRecord(row as IncomeCategoryRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    categoryId: string,
  ): Promise<IncomeCategoryRecord | null> {
    const [row] = await this.db
      .select({
        id: incomeCategories.id,
        name: incomeCategories.name,
        categoryType: incomeCategories.categoryType,
        isSystem: incomeCategories.isSystem,
        incomeCount: sql<number>`(${this.incomeCountSubquery()})`.mapWith(
          Number,
        ),
        totalAmount: sql<string>`coalesce((${this.incomeTotalSubquery()}), '0')`,
        createdAt: incomeCategories.createdAt,
        updatedAt: incomeCategories.updatedAt,
      })
      .from(incomeCategories)
      .where(
        and(
          eq(incomeCategories.id, categoryId),
          eq(incomeCategories.businessId, businessId),
          eq(incomeCategories.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toIncomeCategoryRecord(row as IncomeCategoryRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeCategoryId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(incomeCategories.businessId, businessId),
      eq(incomeCategories.isDeleted, false),
      sql`lower(${incomeCategories.name}) = lower(${name})`,
    ];
    if (excludeCategoryId) {
      conditions.push(ne(incomeCategories.id, excludeCategoryId));
    }

    const [row] = await this.db
      .select({ id: incomeCategories.id })
      .from(incomeCategories)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async countActiveIncomes(
    businessId: string,
    categoryId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({ total: count() })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.categoryId, categoryId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );
    return Number(row?.total ?? 0);
  }

  async create(
    values: IncomeCategoryInsertValues,
  ): Promise<IncomeCategoryRecord> {
    const [row] = await this.db
      .insert(incomeCategories)
      .values({
        businessId: values.businessId,
        name: values.name,
        categoryType: values.categoryType ?? 'direct',
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: incomeCategories.id,
        name: incomeCategories.name,
        categoryType: incomeCategories.categoryType,
        isSystem: incomeCategories.isSystem,
        createdAt: incomeCategories.createdAt,
        updatedAt: incomeCategories.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create income category');
    }

    return toIncomeCategoryRecord({
      ...row,
      incomeCount: 0,
      totalAmount: '0',
    });
  }

  async update(
    businessId: string,
    categoryId: string,
    values: IncomeCategoryUpdateValues,
  ): Promise<IncomeCategoryRecord | null> {
    const [row] = await this.db
      .update(incomeCategories)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.categoryType !== undefined
          ? { categoryType: values.categoryType }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${incomeCategories.syncVersion} + 1`,
      })
      .where(
        and(
          eq(incomeCategories.id, categoryId),
          eq(incomeCategories.businessId, businessId),
          eq(incomeCategories.isDeleted, false),
        ),
      )
      .returning({
        id: incomeCategories.id,
        name: incomeCategories.name,
        categoryType: incomeCategories.categoryType,
        isSystem: incomeCategories.isSystem,
        createdAt: incomeCategories.createdAt,
        updatedAt: incomeCategories.updatedAt,
      });

    if (!row) return null;

    const incomeCount = await this.countActiveIncomes(businessId, categoryId);
    const [totalRow] = await this.db
      .select({ total: sum(otherIncomes.amount) })
      .from(otherIncomes)
      .where(
        and(
          eq(otherIncomes.categoryId, categoryId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );

    return toIncomeCategoryRecord({
      ...row,
      incomeCount,
      totalAmount: totalRow?.total ?? '0',
    });
  }

  async softDelete(
    businessId: string,
    categoryId: string,
    userId: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(incomeCategories)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${incomeCategories.syncVersion} + 1`,
      })
      .where(
        and(
          eq(incomeCategories.id, categoryId),
          eq(incomeCategories.businessId, businessId),
          eq(incomeCategories.isDeleted, false),
        ),
      )
      .returning({ id: incomeCategories.id });

    return Boolean(row);
  }

  async findRawById(
    businessId: string,
    categoryId: string,
  ): Promise<{ isSystem: boolean } | null> {
    const [row] = await this.db
      .select({ isSystem: incomeCategories.isSystem })
      .from(incomeCategories)
      .where(
        and(
          eq(incomeCategories.id, categoryId),
          eq(incomeCategories.businessId, businessId),
          eq(incomeCategories.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }
}
