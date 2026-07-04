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

export class ExpenseReportsRepository {
  constructor(private readonly db: Database) {}

  async getExpenses(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{ payload: PaginatedRowsPayload<ReportExpenseRow>; total: number }> {
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
        date: expenses.expenseDate,
        expenseNo: expenses.referenceNumber,
        partyName: parties.name,
        category: expenseCategories.name,
        amount: expenses.amount,
        paymentMode: expenses.paymentMode,
      })
      .from(expenses)
      .innerJoin(
        expenseCategories,
        eq(expenses.categoryId, expenseCategories.id),
      )
      .leftJoin(parties, eq(expenses.partyId, parties.id))
      .where(and(...filters))
      .orderBy(desc(expenses.expenseDate));

    const mapped = rows.map((row) => ({
      date: new Date(row.date).toISOString(),
      expense_no: row.expenseNo ?? '',
      party_name: row.partyName,
      category: row.category ?? '',
      amount: row.amount ?? '0',
      due_date: new Date(row.date).toISOString(),
      status: row.paymentMode ? 'paid' : 'unpaid',
    }));

    const { rows: pageRows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows: pageRows } };
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
          query.category_id
            ? eq(expenses.categoryId, query.category_id)
            : undefined,
        ),
      )
      .groupBy(expenseCategories.id, expenseCategories.name)
      .orderBy(desc(sql`COALESCE(SUM(${expenses.amount}::numeric), 0)`));

    const mapped = grouped.map((row) => ({
      category: row.category ?? '',
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
