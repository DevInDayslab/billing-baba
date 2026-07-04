import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { ExpenseCategoryRepository } from './expense-category.repository';
import type {
  CreateExpenseCategoryBody,
  ListExpenseCategoriesQuery,
  UpdateExpenseCategoryBody,
} from './expense-category.schema';
import type { ExpenseCategoryRecord } from './expense-category.types';
import { PurchasesServiceBase } from './purchases.base-service';

export class ExpenseCategoryService extends PurchasesServiceBase {
  private readonly repository: ExpenseCategoryRepository;

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
    this.repository = new ExpenseCategoryRepository(db);
  }

  async listCategories(
    businessId: string,
    accountId: string,
    query: ListExpenseCategoriesQuery,
  ): Promise<{
    data: ExpenseCategoryRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      sort: query.sort,
      order: query.order,
    });
    return {
      data: result.rows,
      meta: { page: query.page, limit: query.limit, total: result.total },
    };
  }

  async getCategory(
    businessId: string,
    accountId: string,
    categoryId: string,
  ): Promise<ExpenseCategoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const category = await this.repository.findById(businessId, categoryId);
    if (!category) {
      throw new AppError('NOT_FOUND', 'Expense category not found', 404);
    }
    return category;
  }

  async createCategory(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateExpenseCategoryBody,
  ): Promise<ExpenseCategoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const name = input.name.trim();
    await this.assertNameAvailable(businessId, name);
    return this.repository.create({
      businessId,
      name,
      categoryType: input.category_type,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateCategory(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    categoryId: string,
    input: UpdateExpenseCategoryBody,
  ): Promise<ExpenseCategoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const raw = await this.repository.findRawById(businessId, categoryId);
    if (!raw) {
      throw new AppError('NOT_FOUND', 'Expense category not found', 404);
    }
    if (raw.isSystem) {
      throw new AppError(
        'SYSTEM_CATEGORY',
        'System expense categories cannot be modified',
        422,
      );
    }

    if (input.name !== undefined) {
      await this.assertNameAvailable(businessId, input.name.trim(), categoryId);
    }

    const updated = await this.repository.update(businessId, categoryId, {
      ...(input.name !== undefined ? { name: input.name.trim() } : {}),
      ...(input.category_type !== undefined
        ? { categoryType: input.category_type }
        : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Expense category not found', 404);
    }
    return updated;
  }

  async deleteCategory(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    categoryId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    const raw = await this.repository.findRawById(businessId, categoryId);
    if (!raw) {
      throw new AppError('NOT_FOUND', 'Expense category not found', 404);
    }
    if (raw.isSystem) {
      throw new AppError(
        'SYSTEM_CATEGORY',
        'System expense categories cannot be deleted',
        422,
      );
    }

    const expenseCount = await this.repository.countActiveExpenses(
      businessId,
      categoryId,
    );
    if (expenseCount > 0) {
      throw new AppError(
        'CATEGORY_HAS_EXPENSES',
        'Cannot delete category with existing expenses',
        422,
      );
    }

    const deleted = await this.repository.softDelete(
      businessId,
      categoryId,
      userId ?? null,
    );
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Expense category not found', 404);
    }
  }

  private async assertNameAvailable(
    businessId: string,
    name: string,
    excludeCategoryId?: string,
  ): Promise<void> {
    const conflict = await this.repository.findActiveNameConflict(
      businessId,
      name,
      excludeCategoryId,
    );
    if (conflict) {
      throw new AppError(
        'DUPLICATE_CATEGORY',
        'An expense category with this name already exists',
        409,
      );
    }
  }
}
