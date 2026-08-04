import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { GodownRepository } from './godown.repository';
import type {
  CreateGodownBody,
  ListGodownsQuery,
  UpdateGodownBody,
} from './godown.schema';
import type { GodownRecord } from './godown.types';
import { InventoryServiceBase } from './inventory.base-service';

export class GodownService extends InventoryServiceBase {
  private readonly repository: GodownRepository;

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
    this.repository = new GodownRepository(db);
  }

  async listGodowns(
    businessId: string,
    accountId: string,
    query: ListGodownsQuery,
  ): Promise<{
    data: GodownRecord[];
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

  async getGodown(
    businessId: string,
    accountId: string,
    godownId: string,
  ): Promise<GodownRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const godown = await this.repository.findById(businessId, godownId);
    if (!godown) {
      throw new AppError('NOT_FOUND', 'Godown not found', 404);
    }

    return godown;
  }

  async createGodown(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateGodownBody,
  ): Promise<GodownRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const name = input.name.trim();
    await this.assertNameAvailable(businessId, name);

    if (input.is_default) {
      await this.repository.clearDefaultFlags(businessId);
    }

    return this.repository.create({
      businessId,
      name,
      address: input.address ?? null,
      isDefault: input.is_default ?? false,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateGodown(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    godownId: string,
    input: UpdateGodownBody,
  ): Promise<GodownRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, godownId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Godown not found', 404);
    }

    if (input.name !== undefined) {
      const name = input.name.trim();
      await this.assertNameAvailable(businessId, name, godownId);
    }

    if (input.is_default === true) {
      await this.repository.clearDefaultFlags(businessId, godownId);
    }

    if (input.is_default === false && existing.is_default) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Cannot unset the only default godown. Set another godown as default first.',
        400,
        { is_default: ['A business must have one default godown'] },
      );
    }

    const updated = await this.repository.update(businessId, godownId, {
      ...(input.name !== undefined ? { name: input.name.trim() } : {}),
      ...(input.address !== undefined ? { address: input.address } : {}),
      ...(input.is_default !== undefined ? { isDefault: input.is_default } : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Godown not found', 404);
    }

    return updated;
  }

  async deleteGodown(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    godownId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findRowById(businessId, godownId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Godown not found', 404);
    }

    if (existing.isDefault) {
      throw new AppError(
        'CANNOT_DELETE_DEFAULT_GODOWN',
        'Cannot delete the default godown',
        422,
      );
    }

    const nonZeroStock = await this.repository.countNonZeroStockLevels(
      businessId,
      godownId,
    );
    if (nonZeroStock > 0) {
      throw new AppError(
        'GODOWN_HAS_STOCK',
        'Cannot delete godown with non-zero stock levels',
        422,
      );
    }

    const locationCount = await this.repository.countActiveItemLocations(
      businessId,
      godownId,
    );
    if (locationCount > 0) {
      throw new AppError(
        'GODOWN_HAS_LOCATIONS',
        'Cannot delete godown with item locations',
        422,
      );
    }

    const deleted = await this.repository.softDelete(
      businessId,
      godownId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Godown not found', 404);
    }
  }

  private async assertNameAvailable(
    businessId: string,
    name: string,
    excludeGodownId?: string,
  ): Promise<void> {
    const conflictId = await this.repository.findActiveNameConflict(
      businessId,
      name,
      excludeGodownId,
    );

    if (conflictId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        name: ['A godown with this name already exists'],
      });
    }
  }
}
