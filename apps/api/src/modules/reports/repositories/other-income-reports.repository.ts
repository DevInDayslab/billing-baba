import { and, desc, eq, gte, ilike, lt, or, sql } from 'drizzle-orm';
import type { Database } from '../../../db/client';
import {
  incomeCategories,
  incomeItems,
  otherIncomes,
} from '../../../db/schema/other-income/tables';
import type { ReportExtendedQuery } from '../reports.schema';
import type {
  PaginatedRowsPayload,
  ReportOtherIncomeCategoryRow,
  ReportOtherIncomeItemRow,
  ReportOtherIncomeRow,
} from '../reports.types';
import {
  resolveMoneyEntryBalanceDue,
  resolveMoneyEntryStatus,
} from './money-entry-report.helpers';
import { paginateSlice, resolveRange, toPeriodMeta } from './reports.helpers';

export class OtherIncomeReportsRepository {
  constructor(private readonly db: Database) {}

  async getOtherIncome(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportOtherIncomeRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const filters = [
      eq(otherIncomes.businessId, businessId),
      eq(otherIncomes.isDeleted, false),
      gte(otherIncomes.incomeDate, range.from.toISOString().slice(0, 10)),
      lt(otherIncomes.incomeDate, range.to.toISOString().slice(0, 10)),
    ];

    if (query.category_id) {
      filters.push(eq(otherIncomes.categoryId, query.category_id));
    }
    if (query.payment_mode) {
      filters.push(eq(otherIncomes.paymentMode, query.payment_mode));
    }
    if (query.q) {
      filters.push(
        or(
          ilike(otherIncomes.description, `%${query.q}%`),
          ilike(otherIncomes.referenceNumber, `%${query.q}%`),
        )!,
      );
    }

    const rows = await this.db
      .select({
        date: otherIncomes.incomeDate,
        incomeNo: otherIncomes.referenceNumber,
        category: incomeCategories.name,
        amount: otherIncomes.amount,
        paymentMode: otherIncomes.paymentMode,
        balanceDue: otherIncomes.balanceDue,
        dueDate: otherIncomes.dueDate,
      })
      .from(otherIncomes)
      .innerJoin(
        incomeCategories,
        eq(otherIncomes.categoryId, incomeCategories.id),
      )
      .where(and(...filters))
      .orderBy(desc(otherIncomes.incomeDate));

    const mapped = rows.map((row) => ({
      date: new Date(row.date).toISOString(),
      income_no: row.incomeNo ?? '',
      party_name: null,
      category: row.category ?? '',
      payment_type: row.paymentMode,
      amount: row.amount ?? '0',
      due_date: row.dueDate
        ? new Date(row.dueDate).toISOString()
        : new Date(row.date).toISOString(),
      status: resolveMoneyEntryStatus(
        row.amount,
        row.balanceDue,
        row.paymentMode,
      ),
    }));

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

  async getOtherIncomeByCategory(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportOtherIncomeCategoryRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const grouped = await this.db
      .select({
        category: incomeCategories.name,
        amount: sql<string>`COALESCE(SUM(${otherIncomes.amount}::numeric), 0)`,
        count: sql<number>`COUNT(*)::int`,
      })
      .from(otherIncomes)
      .innerJoin(
        incomeCategories,
        eq(otherIncomes.categoryId, incomeCategories.id),
      )
      .where(
        and(
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
          gte(otherIncomes.incomeDate, range.from.toISOString().slice(0, 10)),
          lt(otherIncomes.incomeDate, range.to.toISOString().slice(0, 10)),
          query.category_id
            ? eq(otherIncomes.categoryId, query.category_id)
            : undefined,
        ),
      )
      .groupBy(incomeCategories.name)
      .orderBy(desc(sql`COALESCE(SUM(${otherIncomes.amount}::numeric), 0)`));

    const mapped = grouped.map((row) => ({
      category: row.category ?? '',
      amount: row.amount ?? '0',
      count: Number(row.count ?? 0),
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }

  async getOtherIncomeByItem(
    businessId: string,
    query: ReportExtendedQuery,
  ): Promise<{
    payload: PaginatedRowsPayload<ReportOtherIncomeItemRow>;
    total: number;
  }> {
    const range = resolveRange(query);

    const grouped = await this.db
      .select({
        itemName: sql<string>`COALESCE(${incomeItems.name}, ${otherIncomes.description}, 'Other income')`,
        category: incomeCategories.name,
        amount: sql<string>`COALESCE(SUM(${otherIncomes.amount}::numeric), 0)`,
        count: sql<number>`COUNT(*)::int`,
      })
      .from(otherIncomes)
      .innerJoin(
        incomeCategories,
        eq(otherIncomes.categoryId, incomeCategories.id),
      )
      .leftJoin(incomeItems, eq(otherIncomes.incomeItemId, incomeItems.id))
      .where(
        and(
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
          gte(otherIncomes.incomeDate, range.from.toISOString().slice(0, 10)),
          lt(otherIncomes.incomeDate, range.to.toISOString().slice(0, 10)),
        ),
      )
      .groupBy(
        incomeItems.name,
        otherIncomes.description,
        incomeCategories.name,
      )
      .orderBy(desc(sql`COALESCE(SUM(${otherIncomes.amount}::numeric), 0)`));

    const mapped = grouped.map((row) => ({
      item_name: row.itemName ?? 'Other income',
      category: row.category ?? '',
      amount: row.amount ?? '0',
      count: Number(row.count ?? 0),
    }));

    const { rows, total } = paginateSlice(mapped, query.page, query.limit);
    return { total, payload: { period: toPeriodMeta(range), rows } };
  }
}
