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
import { parties } from '../../db/schema/crm/tables';
import { expenseCategories, expenses } from '../../db/schema/purchases/tables';
import { toExpenseRecord } from './expense.mapper';
import type {
  ExpenseInsertValues,
  ExpenseRecord,
  ExpenseRow,
  ExpenseUpdateValues,
  ListExpensesParams,
} from './expense.types';

export class ExpenseRepository {
  constructor(private readonly db: Database) {}

  private selectFields() {
    return {
      id: expenses.id,
      categoryId: expenses.categoryId,
      categoryName: expenseCategories.name,
      expenseItemId: expenses.expenseItemId,
      partyId: expenses.partyId,
      partyName: parties.name,
      amount: expenses.amount,
      taxAmount: expenses.taxAmount,
      taxRate: expenses.taxRate,
      description: expenses.description,
      notes: expenses.notes,
      referenceNumber: expenses.referenceNumber,
      attachments: expenses.attachments,
      expenseDate: expenses.expenseDate,
      paymentMode: expenses.paymentMode,
      bankAccountId: expenses.bankAccountId,
      sourceReferenceId: expenses.sourceReferenceId,
      sourceReferenceType: expenses.sourceReferenceType,
      loyaltyPoints: expenses.loyaltyPoints,
      dueDate: expenses.dueDate,
      balanceDue: expenses.balanceDue,
      createdAt: expenses.createdAt,
      updatedAt: expenses.updatedAt,
    };
  }

  private baseJoin() {
    return this.db
      .select(this.selectFields())
      .from(expenses)
      .innerJoin(
        expenseCategories,
        eq(expenses.categoryId, expenseCategories.id),
      )
      .leftJoin(parties, eq(expenses.partyId, parties.id));
  }

  async list(params: ListExpensesParams): Promise<{
    rows: ExpenseRecord[];
    total: number;
  }> {
    const filters = [
      eq(expenses.businessId, params.businessId),
      eq(expenses.isDeleted, false),
    ];

    if (params.q) {
      filters.push(
        or(
          ilike(expenses.description, `%${params.q}%`),
          ilike(expenses.notes, `%${params.q}%`),
          ilike(expenses.referenceNumber, `%${params.q}%`),
          ilike(expenseCategories.name, `%${params.q}%`),
          ilike(parties.name, `%${params.q}%`),
        )!,
      );
    }
    if (params.categoryId) {
      filters.push(eq(expenses.categoryId, params.categoryId));
    }
    if (params.partyId) {
      filters.push(eq(expenses.partyId, params.partyId));
    }
    if (params.from) {
      filters.push(gte(expenses.expenseDate, params.from));
    }
    if (params.to) {
      filters.push(lte(expenses.expenseDate, params.to));
    }
    if (params.minAmount) {
      filters.push(gte(expenses.amount, params.minAmount));
    }
    if (params.maxAmount) {
      filters.push(lte(expenses.amount, params.maxAmount));
    }
    if (params.paymentMode) {
      filters.push(
        eq(
          expenses.paymentMode,
          params.paymentMode as (typeof expenses.paymentMode.enumValues)[number],
        ),
      );
    }

    const whereClause = and(...filters);
    const countResult = await this.db
      .select({ total: count() })
      .from(expenses)
      .innerJoin(
        expenseCategories,
        eq(expenses.categoryId, expenseCategories.id),
      )
      .leftJoin(parties, eq(expenses.partyId, parties.id))
      .where(whereClause);
    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at'
        ? expenses.createdAt
        : params.sort === 'amount'
          ? expenses.amount
          : expenses.expenseDate;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.baseJoin()
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toExpenseRecord(row as ExpenseRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    expenseId: string,
  ): Promise<ExpenseRecord | null> {
    const [row] = await this.baseJoin()
      .where(
        and(
          eq(expenses.id, expenseId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toExpenseRecord(row as ExpenseRow) : null;
  }

  async create(values: ExpenseInsertValues): Promise<ExpenseRecord> {
    const [row] = await this.db
      .insert(expenses)
      .values({
        businessId: values.businessId,
        categoryId: values.categoryId,
        expenseItemId: values.expenseItemId ?? null,
        partyId: values.partyId ?? null,
        amount: values.amount,
        taxAmount: values.taxAmount ?? '0',
        taxRate: values.taxRate ?? '0',
        description: values.description ?? null,
        notes: values.notes ?? null,
        referenceNumber: values.referenceNumber ?? null,
        attachments: values.attachments ?? [],
        expenseDate: values.expenseDate,
        paymentMode: (values.paymentMode ?? null) as
          | (typeof expenses.paymentMode.enumValues)[number]
          | null,
        bankAccountId: values.bankAccountId ?? null,
        sourceReferenceId: values.sourceReferenceId ?? null,
        sourceReferenceType: values.sourceReferenceType ?? null,
        loyaltyPoints: values.loyaltyPoints ?? null,
        dueDate: values.dueDate ?? null,
        balanceDue: values.balanceDue ?? '0',
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({ id: expenses.id });

    if (!row) {
      throw new Error('Failed to create expense');
    }

    const created = await this.findById(values.businessId, row.id);
    if (!created) {
      throw new Error('Failed to load created expense');
    }
    return created;
  }

  async update(
    businessId: string,
    expenseId: string,
    values: ExpenseUpdateValues,
  ): Promise<ExpenseRecord | null> {
    const [row] = await this.db
      .update(expenses)
      .set({
        ...(values.categoryId !== undefined
          ? { categoryId: values.categoryId }
          : {}),
        ...(values.expenseItemId !== undefined
          ? { expenseItemId: values.expenseItemId }
          : {}),
        ...(values.partyId !== undefined ? { partyId: values.partyId } : {}),
        ...(values.amount !== undefined ? { amount: values.amount } : {}),
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
        ...(values.attachments !== undefined
          ? { attachments: values.attachments }
          : {}),
        ...(values.expenseDate !== undefined
          ? { expenseDate: values.expenseDate }
          : {}),
        ...(values.paymentMode !== undefined
          ? {
              paymentMode: values.paymentMode as
                | (typeof expenses.paymentMode.enumValues)[number]
                | null,
            }
          : {}),
        ...(values.bankAccountId !== undefined
          ? { bankAccountId: values.bankAccountId }
          : {}),
        ...(values.sourceReferenceId !== undefined
          ? { sourceReferenceId: values.sourceReferenceId }
          : {}),
        ...(values.sourceReferenceType !== undefined
          ? { sourceReferenceType: values.sourceReferenceType }
          : {}),
        ...(values.loyaltyPoints !== undefined
          ? { loyaltyPoints: values.loyaltyPoints }
          : {}),
        ...(values.dueDate !== undefined ? { dueDate: values.dueDate } : {}),
        ...(values.balanceDue !== undefined
          ? { balanceDue: values.balanceDue }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${expenses.syncVersion} + 1`,
      })
      .where(
        and(
          eq(expenses.id, expenseId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
        ),
      )
      .returning({ id: expenses.id });

    if (!row) return null;
    return this.findById(businessId, expenseId);
  }

  async restoreFromRecycle(
    businessId: string,
    expenseId: string,
    userId: string | null,
  ): Promise<ExpenseRecord | null> {
    const [row] = await this.db
      .update(expenses)
      .set({
        isDeleted: false,
        deletedAt: null,
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${expenses.syncVersion} + 1`,
      })
      .where(
        and(
          eq(expenses.id, expenseId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, true),
        ),
      )
      .returning({ id: expenses.id });

    if (!row) return null;
    return this.findById(businessId, expenseId);
  }

  async purgeFromRecycle(
    businessId: string,
    expenseId: string,
  ): Promise<boolean> {
    const result = await this.db
      .delete(expenses)
      .where(
        and(
          eq(expenses.id, expenseId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, true),
        ),
      )
      .returning({ id: expenses.id });

    return result.length > 0;
  }

  async softDelete(
    businessId: string,
    expenseId: string,
    userId: string | null,
  ): Promise<ExpenseRecord | null> {
    const existing = await this.findById(businessId, expenseId);
    if (!existing) return null;

    await this.db
      .update(expenses)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedBy: userId,
        updatedAt: new Date(),
        syncVersion: sql`${expenses.syncVersion} + 1`,
      })
      .where(
        and(
          eq(expenses.id, expenseId),
          eq(expenses.businessId, businessId),
          eq(expenses.isDeleted, false),
        ),
      );

    return existing;
  }

  async findBySourceReference(
    businessId: string,
    sourceReferenceId: string,
    sourceReferenceType: string,
  ): Promise<ExpenseRecord | null> {
    const [row] = await this.baseJoin()
      .where(
        and(
          eq(expenses.businessId, businessId),
          eq(expenses.sourceReferenceId, sourceReferenceId),
          eq(expenses.sourceReferenceType, sourceReferenceType),
          eq(expenses.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toExpenseRecord(row as ExpenseRow) : null;
  }

  async softDeleteBySource(
    businessId: string,
    sourceReferenceId: string,
    sourceReferenceType: string,
    userId: string | null,
  ): Promise<void> {
    const existing = await this.findBySourceReference(
      businessId,
      sourceReferenceId,
      sourceReferenceType,
    );
    if (!existing) return;

    await this.softDelete(businessId, existing.id, userId);
  }

  async categoryExists(
    businessId: string,
    categoryId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: expenseCategories.id })
      .from(expenseCategories)
      .where(
        and(
          eq(expenseCategories.id, categoryId),
          eq(expenseCategories.businessId, businessId),
          eq(expenseCategories.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }

  async partyExists(businessId: string, partyId: string): Promise<boolean> {
    const [row] = await this.db
      .select({ id: parties.id })
      .from(parties)
      .where(
        and(
          eq(parties.id, partyId),
          eq(parties.businessId, businessId),
          eq(parties.isDeleted, false),
        ),
      )
      .limit(1);
    return Boolean(row);
  }
}
