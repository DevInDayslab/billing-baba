import { and, desc, eq, gte, ilike, lt, or, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import { parties } from '../../../db/schema/crm/tables';
import {
  expenseCategories,
  expenses,
} from '../../../db/schema/purchases/tables';
import type { ReportExtendedQuery } from '../reports.schema';
import type {
  PaginatedRowsPayload,
  ReportExpenseCategoryRow,
  ReportExpenseItemRow,
  ReportExpenseRow,
} from '../reports.types';
import { paginateSlice, resolveRange, toPeriodMeta } from './reports.helpers';

function resolveExpenseBalanceDue(
  amount: string | null,
  balanceDue: string | null,
  paymentMode: string | null,
): number {
  const parsedAmount = Number(amount ?? 0);
  if (balanceDue != null && balanceDue !== '') {
    return Number(balanceDue);
  }
  if (paymentMode) {
    return 0;
  }
  return parsedAmount;
}

function resolveExpenseStatus(
  amount: string | null,
  balanceDue: string | null,
  paymentMode: string | null,
): ReportExpenseRow['status'] {
  const balance = resolveExpenseBalanceDue(amount, balanceDue, paymentMode);
  if (balance <= 0) {
    return 'paid';
  }
  if (paymentMode) {
    return 'partial';
  }
  return 'pending';
}

export class ExpenseReportsRepository {
  constructor(private readonly db: Database) {}

  async getExpenses(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportExpenseRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const filters = [
      eq(expenses.businessId, businessId),
      eq(expenses.isDeleted, false),
      gte(expenses.expenseDate, range.from.toISOString().slice(0, 10)),
      lt(expenses.expenseDate, range.to.toISOString().slice(0, 10)),
    ];

    if (query.category_id) {
      filters.push(eq(expenses.categoryId, query.category_id));
    }
    if (query.payment_mode) {
      filters.push(eq(expenses.paymentMode, query.payment_mode));
    }
    if (query.party_id) {
      filters.push(eq(expenses.partyId, query.party_id));
    }
    if (query.q) {
      filters.push(
        or(
          ilike(expenses.description, `%${query.q}%`),
          ilike(expenses.referenceNumber, `%${query.q}%`),
        )!,
      );
    }

    const rows = await this.db
      .select({
        id: expenses.id,
        date: expenses.expenseDate,
        expenseNo: expenses.referenceNumber,
        partyName: parties.name,
        category: expenseCategories.name,
        amount: expenses.amount,
        paymentMode: expenses.paymentMode,
        balanceDue: expenses.balanceDue,
        dueDate: expenses.dueDate,
      })
      .from(expenses)
      .innerJoin(
        expenseCategories,
        eq(expenses.categoryId, expenseCategories.id),
      )
      .leftJoin(parties, eq(expenses.partyId, parties.id))
      .where(and(...filters))
      .orderBy(desc(expenses.expenseDate));

    const mapped = rows.map((row) => {
      const balanceDue = resolveExpenseBalanceDue(
        row.amount,
        row.balanceDue,
        row.paymentMode,
      );
      return {
        id: row.id,
        date: new Date(row.date).toISOString(),
        expense_no: row.expenseNo ?? '',
        party_name: row.partyName,
        category: row.category ?? '',
        payment_mode: row.paymentMode,
        amount: row.amount ?? '0',
        balance_due: String(balanceDue),
        due_date: row.dueDate
          ? new Date(row.dueDate).toISOString()
          : null,
        status: resolveExpenseStatus(
          row.amount,
          row.balanceDue,
          row.paymentMode,
        ),
      };
    });

    const totalAmount = mapped.reduce(
      (sum, row) => sum + Number(row.amount ?? 0),
      0,
    );

    const { rows: pageRows, total } = paginateSlice(
      mapped,
      query.page,
      query.limit,
    );
    return {
      total,
      payload: {
        period: toPeriodMeta(range),
        total_amount: String(totalAmount),
        rows: pageRows,
      },
    };
  }

  async getExpenseByCategory(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportExpenseCategoryRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const grouped = await this.db
      .select({
        categoryId: expenseCategories.id,
        category: expenseCategories.name,
        categoryType: expenseCategories.categoryType,
        amount: sql<string>`COALESCE(SUM(${expenses.amount}::numeric), 0)`,
        count: sql<number>`COUNT(*)::int`,
      })
      .from(expenses)
      .innerJoin(
        expenseCategories,
        eq(expenses.categoryId, expenseCategories.id),
      )
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
          gte(expenses.expenseDate, range.from.toISOString().slice(0, 10)),
          lt(expenses.expenseDate, range.to.toISOString().slice(0, 10)),
          query.category_id
            ? eq(expenses.categoryId, query.category_id)
            : undefined,
        ),
      )
      .groupBy(
        expenseCategories.id,
        expenseCategories.name,
        expenseCategories.categoryType,
      )
      .orderBy(desc(sql`COALESCE(SUM(${expenses.amount}::numeric), 0)`));

    const mapped = grouped.map((row) => ({
      category_id: row.categoryId,
      category: row.category ?? '',
      category_type: row.categoryType ?? 'direct',
      amount: row.amount ?? '0',
      count: Number(row.count ?? 0),
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getExpenseByItem(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportExpenseItemRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const grouped = await this.db
      .select({
        itemName: expenses.description,
        category: expenseCategories.name,
        amount: sql<string>`COALESCE(SUM(${expenses.amount}::numeric), 0)`,
        count: sql<number>`COUNT(*)::int`,
      })
      .from(expenses)
      .innerJoin(
        expenseCategories,
        eq(expenses.categoryId, expenseCategories.id),
      )
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
          gte(expenses.expenseDate, range.from.toISOString().slice(0, 10)),
          lt(expenses.expenseDate, range.to.toISOString().slice(0, 10)),
        ),
      )
      .groupBy(expenses.description, expenseCategories.name)
      .orderBy(desc(sql`COALESCE(SUM(${expenses.amount}::numeric), 0)`));

    const mapped = grouped.map((row) => ({
      item_name: row.itemName ?? 'Expense',
      category: row.category ?? '',
      amount: row.amount ?? '0',
      count: Number(row.count ?? 0),
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }
}
