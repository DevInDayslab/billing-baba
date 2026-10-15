import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { PurchasesServiceBase } from '../purchases/purchases.base-service';
import { IncomeCategoryRepository } from './income-category.repository';
import type {
  CreateIncomeCategoryBody,
  ListIncomeCategoriesQuery,
  UpdateIncomeCategoryBody,
} from './income-category.schema';
import type { IncomeCategoryRecord } from './income-category.types';

export class IncomeCategoryService extends PurchasesServiceBase {
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly repository: IncomeCategoryRepository;

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
    this.repository = new IncomeCategoryRepository(db);
  }

  async listCategories(
    businessId: string,
    accountId: string,
    query: ListIncomeCategoriesQuery,
  ): Promise<{
    data: IncomeCategoryRecord[];
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
  ): Promise<IncomeCategoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const category = await this.repository.findById(businessId, categoryId);
    if (!category) {
      throw new AppError('NOT_FOUND', 'Income category not found', 404);
    }
    return category;
  }

  async createCategory(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateIncomeCategoryBody,
  ): Promise<IncomeCategoryRecord> {
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
    input: UpdateIncomeCategoryBody,
  ): Promise<IncomeCategoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    const raw = await this.repository.findRawById(businessId, categoryId);
    if (!raw) {
      throw new AppError('NOT_FOUND', 'Income category not found', 404);
    }
    if (raw.isSystem) {
      throw new AppError(
        'SYSTEM_CATEGORY',
        'System income categories cannot be modified',
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
      throw new AppError('NOT_FOUND', 'Income category not found', 404);
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
      throw new AppError('NOT_FOUND', 'Income category not found', 404);
    }
    if (raw.isSystem) {
      throw new AppError(
        'SYSTEM_CATEGORY',
        'System income categories cannot be deleted',
        422,
      );
    }

    const incomeCount = await this.repository.countActiveIncomes(
      businessId,
      categoryId,
    );
    if (incomeCount > 0) {
      throw new AppError(
        'CATEGORY_HAS_INCOMES',
        'Cannot delete category with existing other incomes',
        422,
      );
    }

    const deleted = await this.repository.softDelete(
      businessId,
      categoryId,
      userId ?? null,
    );
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Income category not found', 404);
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
        'An income category with this name already exists',
        409,
      );
    }
  }
}
