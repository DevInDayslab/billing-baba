import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { BrandRepository } from './brand.repository';
import type {
  CreateBrandBody,
  ListBrandsQuery,
  UpdateBrandBody,
} from './brand.schema';
import type { BrandRecord } from './brand.types';
import { InventoryServiceBase } from './inventory.base-service';

export class BrandService extends InventoryServiceBase {
  private readonly repository: BrandRepository;

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
    this.repository = new BrandRepository(db);
  }

  async listBrands(
    businessId: string,
    accountId: string,
    query: ListBrandsQuery,
  ): Promise<{
    data: BrandRecord[];
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

  async getBrand(
    businessId: string,
    accountId: string,
    brandId: string,
  ): Promise<BrandRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const brand = await this.repository.findById(businessId, brandId);
    if (!brand) {
      throw new AppError('NOT_FOUND', 'Brand not found', 404);
    }

    return brand;
  }

  async createBrand(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateBrandBody,
  ): Promise<BrandRecord> {
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

  async updateBrand(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    brandId: string,
    input: UpdateBrandBody,
  ): Promise<BrandRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, brandId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Brand not found', 404);
    }

    if (input.name !== undefined) {
      const name = input.name.trim();
      await this.assertNameAvailable(businessId, name, brandId);
    }

    const updated = await this.repository.update(businessId, brandId, {
      ...(input.name !== undefined ? { name: input.name.trim() } : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Brand not found', 404);
    }

    return updated;
  }

  async deleteBrand(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    brandId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, brandId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Brand not found', 404);
    }

    const itemCount = await this.repository.countActiveItems(
      businessId,
      brandId,
    );

    if (itemCount > 0) {
      throw new AppError(
        'BRAND_HAS_ITEMS',
        'Cannot delete brand with existing active items',
        422,
      );
    }

    const deleted = await this.repository.softDelete(
      businessId,
      brandId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Brand not found', 404);
    }
  }

  private async assertNameAvailable(
    businessId: string,
    name: string,
    excludeBrandId?: string,
  ): Promise<void> {
    const conflictId = await this.repository.findActiveNameConflict(
      businessId,
      name,
      excludeBrandId,
    );

    if (conflictId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        name: ['A brand with this name already exists'],
      });
    }
  }
}
