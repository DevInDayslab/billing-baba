import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import {
  syncOtherIncomeMovement,
  voidOtherIncomeMovement,
} from '../bank-accounts/other-income-movement.helper';
import { PurchasesServiceBase } from '../purchases/purchases.base-service';
import { OtherIncomeRepository } from './other-income.repository';
import type {
  CreateOtherIncomeBody,
  ListOtherIncomesQuery,
  UpdateOtherIncomeBody,
} from './other-income.schema';
import type { OtherIncomeRecord } from './other-income.types';

export class OtherIncomeService extends PurchasesServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: OtherIncomeRepository;

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
    this.repository = new OtherIncomeRepository(db);
  }

  async listOtherIncomes(
    businessId: string,
    accountId: string,
    query: ListOtherIncomesQuery,
  ): Promise<{
    data: OtherIncomeRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      categoryId: query.category_id,
      incomeItemId: query.income_item_id,
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

  async getOtherIncome(
    businessId: string,
    accountId: string,
    otherIncomeId: string,
  ): Promise<OtherIncomeRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const income = await this.repository.findById(businessId, otherIncomeId);
    if (!income) {
      throw new AppError('NOT_FOUND', 'Other income not found', 404);
    }
    return income;
  }

  async createOtherIncome(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateOtherIncomeBody,
  ): Promise<OtherIncomeRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.validateOtherIncomeInput(businessId, input);

    return this.db.transaction(async (tx) => {
      const repo = new OtherIncomeRepository(tx as unknown as typeof this.db);
      const income = await repo.create({
        businessId,
        categoryId: input.category_id,
        incomeItemId: input.income_item_id ?? null,
        amount: input.amount,
        quantity: input.quantity ?? null,
        taxAmount: input.tax_amount ?? '0',
        taxRate: input.tax_rate ?? '0',
        description: input.description ?? null,
        notes: input.notes ?? null,
        referenceNumber: input.reference_number ?? null,
        incomeDate: input.income_date,
        paymentMode: input.payment_mode ?? null,
        bankAccountId: input.bank_account_id ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      await syncOtherIncomeMovement(
        tx as unknown as typeof this.db,
        businessId,
        income,
        userId,
      );
      return income;
    });
  }

  async updateOtherIncome(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    otherIncomeId: string,
    input: UpdateOtherIncomeBody,
  ): Promise<OtherIncomeRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, otherIncomeId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Other income not found', 404);
    }

    if (input.amount !== undefined) {
      this.assertPositiveAmount(input.amount);
    }

    if (input.category_id !== undefined) {
      await this.assertCategoryExists(businessId, input.category_id);
    }

    if (input.income_item_id) {
      await this.assertIncomeItemExists(businessId, input.income_item_id);
    }

    return this.db.transaction(async (tx) => {
      const repo = new OtherIncomeRepository(tx as unknown as typeof this.db);

      const updated = await repo.update(businessId, otherIncomeId, {
        ...(input.category_id !== undefined
          ? { categoryId: input.category_id }
          : {}),
        ...(input.income_item_id !== undefined
          ? { incomeItemId: input.income_item_id }
          : {}),
        ...(input.amount !== undefined ? { amount: input.amount } : {}),
        ...(input.quantity !== undefined ? { quantity: input.quantity } : {}),
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
        ...(input.income_date !== undefined
          ? { incomeDate: input.income_date }
          : {}),
        ...(input.payment_mode !== undefined
          ? { paymentMode: input.payment_mode }
          : {}),
        ...(input.bank_account_id !== undefined
          ? { bankAccountId: input.bank_account_id }
          : {}),
        updatedBy: userId ?? null,
      });

      if (!updated) {
        throw new AppError('NOT_FOUND', 'Other income not found', 404);
      }

      await syncOtherIncomeMovement(
        tx as unknown as typeof this.db,
        businessId,
        updated,
        userId,
      );
      return updated;
    });
  }

  async deleteOtherIncome(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    otherIncomeId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, otherIncomeId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Other income not found', 404);
    }

    await this.db.transaction(async (tx) => {
      const repo = new OtherIncomeRepository(tx as unknown as typeof this.db);
      const deleted = await repo.softDelete(
        businessId,
        otherIncomeId,
        userId ?? null,
      );
      if (!deleted) {
        throw new AppError('NOT_FOUND', 'Other income not found', 404);
      }
      await voidOtherIncomeMovement(
        tx as unknown as typeof this.db,
        businessId,
        otherIncomeId,
      );
    });
  }

  private async validateOtherIncomeInput(
    businessId: string,
    input: CreateOtherIncomeBody,
  ): Promise<void> {
    this.assertPositiveAmount(input.amount);
    await this.assertCategoryExists(businessId, input.category_id);
    if (input.income_item_id) {
      await this.assertIncomeItemExists(businessId, input.income_item_id);
    }
  }

  private assertPositiveAmount(amount: string): void {
    if (Number(amount) <= 0) {
      throw new AppError(
        'INVALID_AMOUNT',
        'Income amount must be greater than zero',
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
      throw new AppError('NOT_FOUND', 'Income category not found', 404);
    }
  }

  private async assertIncomeItemExists(
    businessId: string,
    incomeItemId: string,
  ): Promise<void> {
    const exists = await this.repository.incomeItemExists(
      businessId,
      incomeItemId,
    );
    if (!exists) {
      throw new AppError('NOT_FOUND', 'Income item not found', 404);
    }
  }

  async restoreOtherIncome(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    otherIncomeId: string,
  ): Promise<OtherIncomeRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    return this.db.transaction(async (tx) => {
      const repo = new OtherIncomeRepository(tx as unknown as typeof this.db);
      const restored = await repo.restoreFromRecycle(
        businessId,
        otherIncomeId,
        userId ?? null,
      );
      if (!restored) {
        throw new AppError('NOT_FOUND', 'Deleted other income not found', 404);
      }
      await syncOtherIncomeMovement(
        tx as unknown as typeof this.db,
        businessId,
        restored,
        userId,
      );
      return restored;
    });
  }

  async purgeOtherIncome(
    businessId: string,
    accountId: string,
    _userId: string | undefined,
    otherIncomeId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    const purged = await this.repository.purgeFromRecycle(
      businessId,
      otherIncomeId,
    );
    if (!purged) {
      throw new AppError('NOT_FOUND', 'Deleted other income not found', 404);
    }
  }
}
