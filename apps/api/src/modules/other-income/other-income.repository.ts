import {
  and,
  asc,
  count,
  desc,
  eq,
  gte,
  ilike,
  lte,
  or,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  incomeCategories,
  incomeItems,
  otherIncomes,
} from '../../db/schema/other-income/tables';
import { toOtherIncomeRecord } from './other-income.mapper';
import type {
  ListOtherIncomesParams,
  OtherIncomeInsertValues,
  OtherIncomeRecord,
  OtherIncomeRow,
  OtherIncomeUpdateValues,
} from './other-income.types';

export class OtherIncomeRepository {
  constructor(private readonly db: Database) {}

  private selectFields() {
    return {
      id: otherIncomes.id,
      categoryId: otherIncomes.categoryId,
      categoryName: incomeCategories.name,
      incomeItemId: otherIncomes.incomeItemId,
      incomeItemName: incomeItems.name,
      amount: otherIncomes.amount,
      quantity: otherIncomes.quantity,
      taxAmount: otherIncomes.taxAmount,
      taxRate: otherIncomes.taxRate,
      description: otherIncomes.description,
      notes: otherIncomes.notes,
      referenceNumber: otherIncomes.referenceNumber,
      incomeDate: otherIncomes.incomeDate,
      paymentMode: otherIncomes.paymentMode,
      bankAccountId: otherIncomes.bankAccountId,
      dueDate: otherIncomes.dueDate,
      balanceDue: otherIncomes.balanceDue,
      createdAt: otherIncomes.createdAt,
      updatedAt: otherIncomes.updatedAt,
    };
  }

  private baseJoin() {
    return this.db
      .select(this.selectFields())
      .from(otherIncomes)
      .innerJoin(
        incomeCategories,
        eq(otherIncomes.categoryId, incomeCategories.id),
      )
      .leftJoin(incomeItems, eq(otherIncomes.incomeItemId, incomeItems.id));
  }

  async list(params: ListOtherIncomesParams): Promise<{
    rows: OtherIncomeRecord[];
    total: number;
  }> {
    const filters = [
      eq(otherIncomes.businessId, params.businessId),
      eq(otherIncomes.isDeleted, false),
    ];

    if (params.q) {
      filters.push(
        or(
          ilike(otherIncomes.description, `%${params.q}%`),
          ilike(otherIncomes.notes, `%${params.q}%`),
          ilike(otherIncomes.referenceNumber, `%${params.q}%`),
          ilike(incomeCategories.name, `%${params.q}%`),
          ilike(incomeItems.name, `%${params.q}%`),
        )!,
      );
    }
    if (params.categoryId) {
      filters.push(eq(otherIncomes.categoryId, params.categoryId));
    }
    if (params.incomeItemId) {
      filters.push(eq(otherIncomes.incomeItemId, params.incomeItemId));
    }
    if (params.from) {
      filters.push(gte(otherIncomes.incomeDate, params.from));
    }
    if (params.to) {
      filters.push(lte(otherIncomes.incomeDate, params.to));
    }
    if (params.minAmount) {
      filters.push(gte(otherIncomes.amount, params.minAmount));
    }
    if (params.maxAmount) {
      filters.push(lte(otherIncomes.amount, params.maxAmount));
    }
    if (params.paymentMode) {
      filters.push(
        eq(
          otherIncomes.paymentMode,
          params.paymentMode as (typeof otherIncomes.paymentMode.enumValues)[number],
        ),
      );
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(otherIncomes)
      .innerJoin(
        incomeCategories,
        eq(otherIncomes.categoryId, incomeCategories.id),
      )
      .leftJoin(incomeItems, eq(otherIncomes.incomeItemId, incomeItems.id))
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? otherIncomes.createdAt
        : params.sort === 'amount'
          ? otherIncomes.amount
          : otherIncomes.incomeDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.baseJoin()
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toOtherIncomeRecord(row as OtherIncomeRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    otherIncomeId: string,
  ): Promise<OtherIncomeRecord | null> {
    const [row] = await this.baseJoin()
      .where(
        and(
          eq(otherIncomes.id, otherIncomeId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toOtherIncomeRecord(row as OtherIncomeRow) : null;
  }

  async create(values: OtherIncomeInsertValues): Promise<OtherIncomeRecord> {
    const [row] = await this.db
      .insert(otherIncomes)
      .values({
        businessId: values.businessId,
        categoryId: values.categoryId,
        incomeItemId: values.incomeItemId ?? null,
        amount: values.amount,
        quantity: values.quantity ?? null,
        taxAmount: values.taxAmount ?? '0',
        taxRate: values.taxRate ?? '0',
        description: values.description ?? null,
        notes: values.notes ?? null,
        referenceNumber: values.referenceNumber ?? null,
        incomeDate: values.incomeDate,
        paymentMode: (values.paymentMode ?? null) as
          | (typeof otherIncomes.paymentMode.enumValues)[number]
          | null,
        bankAccountId: values.bankAccountId ?? null,
        dueDate: values.dueDate ?? null,
        balanceDue: values.balanceDue ?? '0',
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({ id: otherIncomes.id });

    if (!row) {
      throw new Error('Failed to create other income');
    }

    const created = await this.findById(values.businessId, row.id);
    if (!created) {
      throw new Error('Failed to load created other income');
    }
    return created;
  }

  async update(
    businessId: string,
    otherIncomeId: string,
    values: OtherIncomeUpdateValues,
  ): Promise<OtherIncomeRecord | null> {
    const [row] = await this.db
      .update(otherIncomes)
      .set({
        ...(values.categoryId !== undefined
          ? { categoryId: values.categoryId }
          : {}),
        ...(values.incomeItemId !== undefined
          ? { incomeItemId: values.incomeItemId }
          : {}),
        ...(values.amount !== undefined ? { amount: values.amount } : {}),
        ...(values.quantity !== undefined ? { quantity: values.quantity } : {}),
        ...(values.taxAmount !== undefined
          ? { taxAmount: values.taxAmount }
          : {}),
        ...(values.taxRate !== undefined ? { taxRate: values.taxRate } : {}),
        ...(values.description !== undefined
          ? { description: values.description }
          : {}),
        ...(values.notes !== undefined ? { notes: values.notes } : {}),
        ...(values.referenceNumber !== undefined
          ? { referenceNumber: values.referenceNumber }
          : {}),
        ...(values.incomeDate !== undefined
          ? { incomeDate: values.incomeDate }
          : {}),
        ...(values.paymentMode !== undefined
          ? {
              paymentMode: values.paymentMode as
                | (typeof otherIncomes.paymentMode.enumValues)[number]
                | null,
            }
          : {}),
        ...(values.bankAccountId !== undefined
          ? { bankAccountId: values.bankAccountId }
          : {}),
        ...(values.dueDate !== undefined ? { dueDate: values.dueDate } : {}),
        ...(values.balanceDue !== undefined
          ? { balanceDue: values.balanceDue }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${otherIncomes.syncVersion} + 1`,
      })
      .where(
        and(
          eq(otherIncomes.id, otherIncomeId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      )
      .returning({ id: otherIncomes.id });

    if (!row) return null;
    return this.findById(businessId, otherIncomeId);
  }

  async restoreFromRecycle(
    businessId: string,
    otherIncomeId: string,
    userId: string | null,
  ): Promise<OtherIncomeRecord | null> {
    const [row] = await this.db
      .update(otherIncomes)
      .set({
        isDeleted: false,
        deletedAt: null,
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${otherIncomes.syncVersion} + 1`,
      })
      .where(
        and(
          eq(otherIncomes.id, otherIncomeId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, true),
        ),
      )
      .returning({ id: otherIncomes.id });

    if (!row) return null;
    return this.findById(businessId, otherIncomeId);
  }

  async purgeFromRecycle(
    businessId: string,
    otherIncomeId: string,
  ): Promise<boolean> {
    const result = await this.db
      .delete(otherIncomes)
      .where(
        and(
          eq(otherIncomes.id, otherIncomeId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, true),
        ),
      )
      .returning({ id: otherIncomes.id });

    return result.length > 0;
  }

  async softDelete(
    businessId: string,
    otherIncomeId: string,
    userId: string | null,
  ): Promise<OtherIncomeRecord | null> {
    const existing = await this.findById(businessId, otherIncomeId);
    if (!existing) return null;

    await this.db
      .update(otherIncomes)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${otherIncomes.syncVersion} + 1`,
      })
      .where(
        and(
          eq(otherIncomes.id, otherIncomeId),
          eq(otherIncomes.businessId, businessId),
          eq(otherIncomes.isDeleted, false),
        ),
      );

    return existing;
  }

  async categoryExists(
    businessId: string,
    categoryId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: incomeCategories.id })
      .from(incomeCategories)
      .where(
        and(
          eq(incomeCategories.id, categoryId),
          eq(incomeCategories.businessId, businessId),
          eq(incomeCategories.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  async incomeItemExists(
    businessId: string,
    incomeItemId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: incomeItems.id })
      .from(incomeItems)
      .where(
        and(
          eq(incomeItems.id, incomeItemId),
          eq(incomeItems.businessId, businessId),
          eq(incomeItems.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }
}
