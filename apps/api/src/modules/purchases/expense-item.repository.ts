import { and, asc, count, desc, eq, ilike, ne, sql, sum } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { expenseItems, expenses } from '../../db/schema/purchases/tables';
import { toExpenseItemRecord } from './expense-item.mapper';
import type {
  ExpenseItemInsertValues,
  ExpenseItemRecord,
  ExpenseItemRow,
  ExpenseItemUpdateValues,
  ListExpenseItemsParams,
} from './expense-item.types';

export class ExpenseItemRepository {
  constructor(private readonly db: Database) {}

  private expenseCountSubquery() {
    return this.db
      .select({ total: count() })
      .from(expenses)
      .where(
        and(
          eq(expenses.expenseItemId, expenseItems.id),
          eq(expenses.businessId, expenseItems.businessId),
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
          eq(expenses.expenseItemId, expenseItems.id),
          eq(expenses.businessId, expenseItems.businessId),
          eq(expenses.isDeleted, false),
        ),
      );
  }

  async list(params: ListExpenseItemsParams): Promise<{
    rows: ExpenseItemRecord[];
    total: number;
  }> {
    const filters = [
      eq(expenseItems.businessId, params.businessId),
      eq(expenseItems.isDeleted, false),
    ];

    if (params.q) {
      filters.push(ilike(expenseItems.name, `%${params.q}%`));
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(expenseItems)
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? expenseItems.createdAt
        : params.sort === 'price'
          ? expenseItems.price
          : expenseItems.name;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select({
        id: expenseItems.id,
        name: expenseItems.name,
        hsnSac: expenseItems.hsnSac,
        price: expenseItems.price,
        priceIsTaxInclusive: expenseItems.priceIsTaxInclusive,
        taxRate: expenseItems.taxRate,
        expenseCount: sql<number>`(${this.expenseCountSubquery()})`.mapWith(
          Number,
        ),
        totalAmount: sql<string>`coalesce((${this.expenseTotalSubquery()}), '0')`,
        createdAt: expenseItems.createdAt,
        updatedAt: expenseItems.updatedAt,
      })
      .from(expenseItems)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toExpenseItemRecord(row as ExpenseItemRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    itemId: string,
  ): Promise<ExpenseItemRecord | null> {
    const [row] = await this.db
      .select({
        id: expenseItems.id,
        name: expenseItems.name,
        hsnSac: expenseItems.hsnSac,
        price: expenseItems.price,
        priceIsTaxInclusive: expenseItems.priceIsTaxInclusive,
        taxRate: expenseItems.taxRate,
        expenseCount: sql<number>`(${this.expenseCountSubquery()})`.mapWith(
          Number,
        ),
        totalAmount: sql<string>`coalesce((${this.expenseTotalSubquery()}), '0')`,
        createdAt: expenseItems.createdAt,
        updatedAt: expenseItems.updatedAt,
      })
      .from(expenseItems)
      .where(
        and(
          eq(expenseItems.id, itemId),
          eq(expenseItems.businessId, businessId),
          eq(expenseItems.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toExpenseItemRecord(row as ExpenseItemRow) : null;
  }

  async findActiveNameConflict(
    businessId: string,
    name: string,
    excludeItemId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(expenseItems.businessId, businessId),
      eq(expenseItems.isDeleted, false),
      sql`lower(${expenseItems.name}) = lower(${name})`,
    ];
    if (excludeItemId) {
      conditions.push(ne(expenseItems.id, excludeItemId));
    }

    const [row] = await this.db
      .select({ id: expenseItems.id })
      .from(expenseItems)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async create(values: ExpenseItemInsertValues): Promise<ExpenseItemRecord> {
    const [row] = await this.db
      .insert(expenseItems)
      .values({
        businessId: values.businessId,
        name: values.name,
        hsnSac: values.hsnSac ?? null,
        price: values.price ?? '0',
        priceIsTaxInclusive: values.priceIsTaxInclusive ?? false,
        taxRate: values.taxRate ?? '0',
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: expenseItems.id,
        name: expenseItems.name,
        hsnSac: expenseItems.hsnSac,
        price: expenseItems.price,
        priceIsTaxInclusive: expenseItems.priceIsTaxInclusive,
        taxRate: expenseItems.taxRate,
        createdAt: expenseItems.createdAt,
        updatedAt: expenseItems.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create expense item');
    }

    return toExpenseItemRecord({
      ...row,
      expenseCount: 0,
      totalAmount: '0',
    });
  }

  async update(
    businessId: string,
    itemId: string,
    values: ExpenseItemUpdateValues,
  ): Promise<ExpenseItemRecord | null> {
    const [row] = await this.db
      .update(expenseItems)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.hsnSac !== undefined ? { hsnSac: values.hsnSac } : {}),
        ...(values.price !== undefined ? { price: values.price } : {}),
        ...(values.priceIsTaxInclusive !== undefined
          ? { priceIsTaxInclusive: values.priceIsTaxInclusive }
          : {}),
        ...(values.taxRate !== undefined ? { taxRate: values.taxRate } : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${expenseItems.syncVersion} + 1`,
      })
      .where(
        and(
          eq(expenseItems.id, itemId),
          eq(expenseItems.businessId, businessId),
          eq(expenseItems.isDeleted, false),
        ),
      )
      .returning({
        id: expenseItems.id,
        name: expenseItems.name,
        hsnSac: expenseItems.hsnSac,
        price: expenseItems.price,
        priceIsTaxInclusive: expenseItems.priceIsTaxInclusive,
        taxRate: expenseItems.taxRate,
        createdAt: expenseItems.createdAt,
        updatedAt: expenseItems.updatedAt,
      });

    if (!row) return null;

    const expenseCount = await this.countLinkedExpenses(businessId, itemId);
    const [totalRow] = await this.db
      .select({ total: sum(expenses.amount) })
      .from(expenses)
      .where(
        and(
          eq(expenses.expenseItemId, itemId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
        ),
      );

    return toExpenseItemRecord({
      ...row,
      expenseCount,
      totalAmount: totalRow?.total ?? '0',
    });
  }

  async countLinkedExpenses(
    businessId: string,
    itemId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({ total: count() })
      .from(expenses)
      .where(
        and(
          eq(expenses.expenseItemId, itemId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
        ),
      );
    return Number(row?.total ?? 0);
  }

  async softDelete(
    businessId: string,
    itemId: string,
    userId: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(expenseItems)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${expenseItems.syncVersion} + 1`,
      })
      .where(
        and(
          eq(expenseItems.id, itemId),
          eq(expenseItems.businessId, businessId),
          eq(expenseItems.isDeleted, false),
        ),
      )
      .returning({ id: expenseItems.id });

    return Boolean(row);
  }
}
