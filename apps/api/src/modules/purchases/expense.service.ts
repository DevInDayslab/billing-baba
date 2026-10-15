import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { ExpenseRepository } from './expense.repository';
import type {
  CreateExpenseBody,
  ListExpensesQuery,
  UpdateExpenseBody,
} from './expense.schema';
import type { ExpenseRecord } from './expense.types';
import {
  postExpenseLedgerEntry,
  reverseExpenseLedgerEntry,
} from './expense-ledger.service';
import { PurchasesServiceBase } from './purchases.base-service';

export class ExpenseService extends PurchasesServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: ExpenseRepository;

  constructor() {
    super();
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.db = db;
    this.repository = new ExpenseRepository(db);
  }

  async listExpenses(
    businessId: string,
    accountId: string,
    query: ListExpensesQuery,
  ): Promise<{
    data: ExpenseRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      categoryId: query.category_id,
      partyId: query.party_id,
      from: query.from,
      to: query.to,
      minAmount: query.min_amount,
      maxAmount: query.max_amount,
      paymentMode: query.payment_mode,
      sort: query.sort,
      order: query.order,
    });
    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getExpense(
    businessId: string,
    accountId: string,
    expenseId: string,
  ): Promise<ExpenseRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const expense = await this.repository.findById(businessId, expenseId);
    if (!expense) {
      throw new AppError('NOT_FOUND', 'Expense not found', 404);
    }
    return expense;
  }

  async createExpense(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateExpenseBody,
  ): Promise<ExpenseRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.validateExpenseInput(businessId, input);

    return this.db.transaction(async (tx) => {
      const repo = new ExpenseRepository(tx as unknown as typeof this.db);
      const expense = await repo.create({
        businessId,
        categoryId: input.category_id,
        expenseItemId: input.expense_item_id ?? null,
        partyId: input.party_id ?? null,
        amount: input.amount,
        taxAmount: input.tax_amount ?? '0',
        taxRate: input.tax_rate ?? '0',
        description: input.description ?? null,
        notes: input.notes ?? null,
        referenceNumber: input.reference_number ?? null,
        attachments: input.attachments ?? [],
        expenseDate: input.expense_date,
        paymentMode: input.payment_mode ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      await postExpenseLedgerEntry(tx as unknown as typeof this.db, {
        businessId,
        expense,
      });
      return expense;
    });
  }

  async updateExpense(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    expenseId: string,
    input: UpdateExpenseBody,
  ): Promise<ExpenseRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, expenseId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Expense not found', 404);
    }

    if (input.amount !== undefined) {
      this.assertPositiveAmount(input.amount);
    }

    if (input.category_id !== undefined) {
      await this.assertCategoryExists(businessId, input.category_id);
    }

    if (input.party_id) {
      await this.assertPartyExists(businessId, input.party_id);
    }

    return this.db.transaction(async (tx) => {
      const repo = new ExpenseRepository(tx as unknown as typeof this.db);
      await reverseExpenseLedgerEntry(
        tx as unknown as typeof this.db,
        businessId,
        existing,
      );

      const updated = await repo.update(businessId, expenseId, {
        ...(input.category_id !== undefined
          ? { categoryId: input.category_id }
          : {}),
        ...(input.expense_item_id !== undefined
          ? { expenseItemId: input.expense_item_id }
          : {}),
        ...(input.party_id !== undefined ? { partyId: input.party_id } : {}),
        ...(input.amount !== undefined ? { amount: input.amount } : {}),
        ...(input.tax_amount !== undefined
          ? { taxAmount: input.tax_amount }
          : {}),
        ...(input.tax_rate !== undefined ? { taxRate: input.tax_rate } : {}),
        ...(input.description !== undefined
          ? { description: input.description }
          : {}),
        ...(input.notes !== undefined ? { notes: input.notes } : {}),
        ...(input.reference_number !== undefined
          ? { referenceNumber: input.reference_number }
          : {}),
        ...(input.attachments !== undefined
          ? { attachments: input.attachments }
          : {}),
        ...(input.expense_date !== undefined
          ? { expenseDate: input.expense_date }
          : {}),
        ...(input.payment_mode !== undefined
          ? { paymentMode: input.payment_mode }
          : {}),
        updatedBy: userId ?? null,
      });

      if (!updated) {
        throw new AppError('NOT_FOUND', 'Expense not found', 404);
      }

      await postExpenseLedgerEntry(tx as unknown as typeof this.db, {
        businessId,
        expense: updated,
      });
      return updated;
    });
  }

  async deleteExpense(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    expenseId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, expenseId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Expense not found', 404);
    }

    await this.db.transaction(async (tx) => {
      const repo = new ExpenseRepository(tx as unknown as typeof this.db);
      await reverseExpenseLedgerEntry(
        tx as unknown as typeof this.db,
        businessId,
        existing,
      );
      const deleted = await repo.softDelete(
        businessId,
        expenseId,
        userId ?? null,
      );
      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Expense not found', 404);
      }
    });
  }

  private async validateExpenseInput(
    businessId: string,
    input: CreateExpenseBody,
  ): Promise<void> {
    this.assertPositiveAmount(input.amount);
    await this.assertCategoryExists(businessId, input.category_id);
    if (input.party_id) {
      await this.assertPartyExists(businessId, input.party_id);
    }
  }

  private assertPositiveAmount(amount: string): void {
    if (Number(amount) <= 0) {
      throw new AppError(
        'INVALID_AMOUNT',
        'Expense amount must be greater than zero',
        422,
      );
    }
  }

  private async assertCategoryExists(
    businessId: string,
    categoryId: string,
  ): Promise<void> {
    const exists = await this.repository.categoryExists(businessId, categoryId);
    if (!exists) {
      throw new AppError('NOT_FOUND', 'Expense category not found', 404);
    }
  }

  private async assertPartyExists(
    businessId: string,
    partyId: string,
  ): Promise<void> {
    const exists = await this.repository.partyExists(businessId, partyId);
    if (!exists) {
      throw new AppError('NOT_FOUND', 'Party not found', 404);
    }
  }
}
