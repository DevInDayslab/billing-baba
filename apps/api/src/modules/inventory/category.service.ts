import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { CategoryRepository } from './category.repository';
import type {
  CreateCategoryBody,
  ListCategoriesQuery,
  UpdateCategoryBody,
} from './category.schema';
import type { CategoryRecord } from './category.types';
import { InventorySharedRepository } from './inventory.shared-repository';

export class CategoryService {
  private readonly repository: CategoryRepository;
  private readonly sharedRepository: InventorySharedRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new CategoryRepository(db);
    this.sharedRepository = new InventorySharedRepository(db);
  }

  async listCategories(
    businessId: string,
    accountId: string,
    query: ListCategoriesQuery,
  ): Promise<{
    data: CategoryRecord[];
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
      meta: {
        page: query.page,
        limit: query.limit,
        total: result.total,
      },
    };
  }

  async getCategory(
    businessId: string,
    accountId: string,
    categoryId: string,
  ): Promise<CategoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const category = await this.repository.findById(businessId, categoryId);
    if (!category) {
      throw new AppError('NOT_FOUND', 'Category not found', 404);
    }

    return category;
  }

  async createCategory(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateCategoryBody,
  ): Promise<CategoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const name = input.name.trim();
    await this.assertNameAvailable(businessId, name);

    return this.repository.create({
      businessId,
      name,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateCategory(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    categoryId: string,
    input: UpdateCategoryBody,
  ): Promise<CategoryRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, categoryId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Category not found', 404);
    }

    if (input.name !== undefined) {
      const name = input.name.trim();
      await this.assertNameAvailable(businessId, name, categoryId);
    }

    const updated = await this.repository.update(businessId, categoryId, {
      ...(input.name !== undefined ? { name: input.name.trim() } : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Category not found', 404);
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

    const existing = await this.repository.findById(businessId, categoryId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Category not found', 404);
    }

    const itemCount = await this.repository.countActiveItems(
      businessId,
      categoryId,
    );

    if (itemCount > 0) {
      throw new AppError(
        'CATEGORY_HAS_ITEMS',
        'Cannot delete category with existing active items',
        422,
      );
    }

    const deleted = await this.repository.softDelete(
      businessId,
      categoryId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Category not found', 404);
    }
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.sharedRepository.hasBusinessMembership(
      businessId,
      accountId,
    );

    if (!hasAccess) {
      throw new AppError(
        'FORBIDDEN',
        'You do not have access to this business',
        403,
      );
    }
  }

  private async assertNameAvailable(
    businessId: string,
    name: string,
    excludeCategoryId?: string,
  ): Promise<void> {
    const conflictId = await this.repository.findActiveNameConflict(
      businessId,
      name,
      excludeCategoryId,
    );

    if (conflictId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        name: ['A category with this name already exists'],
      });
    }
  }
}
