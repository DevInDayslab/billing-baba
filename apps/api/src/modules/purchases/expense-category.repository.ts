import { and, asc, count, desc, eq, ilike, ne, sql, sum } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { expenseCategories, expenses } from '../../db/schema/purchases/tables';
import { toExpenseCategoryRecord } from './expense-category.mapper';
import type {
  ExpenseCategoryInsertValues,
  ExpenseCategoryRecord,
  ExpenseCategoryRow,
  ExpenseCategoryUpdateValues,
  ListExpenseCategoriesParams,
} from './expense-category.types';

export class ExpenseCategoryRepository {
  constructor(private readonly db: Database) {}

  private expenseCountSubquery() {
    return this.db
      .select({ total: count() })
      .from(expenses)
      .where(
        and(
          eq(expenses.categoryId, expenseCategories.id),
          eq(expenses.businessId, expenseCategories.businessId),
          eq(expenses.isDeleted, false),
        ),
      );
  }

  private expenseTotalSubquery() {
    return this.db
      .select({ total: sum(expenses.amount) })
      .from(expenses)
      .where(
        and(
          eq(expenses.categoryId, expenseCategories.id),
          eq(expenses.businessId, expenseCategories.businessId),
          eq(expenses.isDeleted, false),
        ),
      );
  }

  async list(params: ListExpenseCategoriesParams): Promise<{
    rows: ExpenseCategoryRecord[];
    total: number;
  }> {
    const filters = [
      eq(expenseCategories.businessId, params.businessId),
      eq(expenseCategories.isDeleted, false),
    ];

    if (params.q) {
      filters.push(ilike(expenseCategories.name, `%${params.q}%`));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(expenseCategories)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? expenseCategories.createdAt
        : expenseCategories.name;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: expenseCategories.id,
        name: expenseCategories.name,
        categoryType: expenseCategories.categoryType,
        isSystem: expenseCategories.isSystem,
        expenseCount: sql<number>`(${this.expenseCountSubquery()})`.mapWith(
          Number,
        ),
        totalAmount: sql<string>`coalesce((${this.expenseTotalSubquery()}), '0')`,
        createdAt: expenseCategories.createdAt,
        updatedAt: expenseCategories.updatedAt,
      })
      .from(expenseCategories)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) =>
        toExpenseCategoryRecord(row as ExpenseCategoryRow),
      ),
      total,
    };
  }

  async findById(
    businessId: string,
    categoryId: string,
  ): Promise<ExpenseCategoryRecord | null> {
    const [row] = await this.db
      .select({
        id: expenseCategories.id,
        name: expenseCategories.name,
        categoryType: expenseCategories.categoryType,
        isSystem: expenseCategories.isSystem,
        expenseCount: sql<number>`(${this.expenseCountSubquery()})`.mapWith(
          Number,
        ),
        totalAmount: sql<string>`coalesce((${this.expenseTotalSubquery()}), '0')`,
        createdAt: expenseCategories.createdAt,
        updatedAt: expenseCategories.updatedAt,
      })
      .from(expenseCategories)
      .where(
        and(
          eq(expenseCategories.id, categoryId),
          eq(expenseCategories.businessId, businessId),
          eq(expenseCategories.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toExpenseCategoryRecord(row as ExpenseCategoryRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeCategoryId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(expenseCategories.businessId, businessId),
      eq(expenseCategories.isDeleted, false),
      sql`lower(${expenseCategories.name}) = lower(${name})`,
    ];
    if (excludeCategoryId) {
      conditions.push(ne(expenseCategories.id, excludeCategoryId));
    }

    const [row] = await this.db
      .select({ id: expenseCategories.id })
      .from(expenseCategories)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async countActiveExpenses(
    businessId: string,
    categoryId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({ total: count() })
      .from(expenses)
      .where(
        and(
          eq(expenses.categoryId, categoryId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
        ),
      );
    return Number(row?.total ?? 0);
  }

  async create(
    values: ExpenseCategoryInsertValues,
  ): Promise<ExpenseCategoryRecord> {
    const [row] = await this.db
      .insert(expenseCategories)
      .values({
        businessId: values.businessId,
        name: values.name,
        categoryType: values.categoryType ?? 'direct',
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: expenseCategories.id,
        name: expenseCategories.name,
        categoryType: expenseCategories.categoryType,
        isSystem: expenseCategories.isSystem,
        createdAt: expenseCategories.createdAt,
        updatedAt: expenseCategories.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create expense category');
    }

    return toExpenseCategoryRecord({
      ...row,
      expenseCount: 0,
      totalAmount: '0',
    });
  }

  async update(
    businessId: string,
    categoryId: string,
    values: ExpenseCategoryUpdateValues,
  ): Promise<ExpenseCategoryRecord | null> {
    const [row] = await this.db
      .update(expenseCategories)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.categoryType !== undefined
          ? { categoryType: values.categoryType }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${expenseCategories.syncVersion} + 1`,
      })
      .where(
        and(
          eq(expenseCategories.id, categoryId),
          eq(expenseCategories.businessId, businessId),
          eq(expenseCategories.isDeleted, false),
        ),
      )
      .returning({
        id: expenseCategories.id,
        name: expenseCategories.name,
        categoryType: expenseCategories.categoryType,
        isSystem: expenseCategories.isSystem,
        createdAt: expenseCategories.createdAt,
        updatedAt: expenseCategories.updatedAt,
      });

    if (!row) return null;

    const expenseCount = await this.countActiveExpenses(businessId, categoryId);
    const [totalRow] = await this.db
      .select({ total: sum(expenses.amount) })
      .from(expenses)
      .where(
        and(
          eq(expenses.categoryId, categoryId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
        ),
      );

    return toExpenseCategoryRecord({
      ...row,
      expenseCount,
      totalAmount: totalRow?.total ?? '0',
    });
  }

  async softDelete(
    businessId: string,
    categoryId: string,
    userId: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(expenseCategories)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${expenseCategories.syncVersion} + 1`,
      })
      .where(
        and(
          eq(expenseCategories.id, categoryId),
          eq(expenseCategories.businessId, businessId),
          eq(expenseCategories.isDeleted, false),
        ),
      )
      .returning({ id: expenseCategories.id });

    return Boolean(row);
  }

  async findRawById(
    businessId: string,
    categoryId: string,
  ): Promise<{ isSystem: boolean } | null> {
    const [row] = await this.db
      .select({ isSystem: expenseCategories.isSystem })
      .from(expenseCategories)
      .where(
        and(
          eq(expenseCategories.id, categoryId),
          eq(expenseCategories.businessId, businessId),
          eq(expenseCategories.isDeleted, false),
        ),
      )
      .limit(1);
    return row ?? null;
  }
}
