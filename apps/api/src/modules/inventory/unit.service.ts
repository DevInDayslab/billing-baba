import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import { UnitRepository } from './unit.repository';
import type {
  CreateUnitBody,
  ListUnitsQuery,
  UpdateUnitBody,
} from './unit.schema';
import type { UnitListRecord, UnitRecord } from './unit.types';

export class UnitService extends InventoryServiceBase {
  private readonly repository: UnitRepository;

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
    this.repository = new UnitRepository(db);
  }

  async listUnits(
    businessId: string,
    accountId: string,
    query: ListUnitsQuery,
  ): Promise<{
    data: UnitListRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      isActive: query.is_active,
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

  async getUnit(
    businessId: string,
    accountId: string,
    unitId: string,
  ): Promise<UnitRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const unit = await this.repository.findById(businessId, unitId);
    if (!unit) {
      throw new AppError('NOT_FOUND', 'Unit not found', 404);
    }

    return unit;
  }

  async createUnit(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateUnitBody,
  ): Promise<UnitRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const name = input.name.trim();
    const shortName = input.short_name.trim();

    await this.assertNamesAvailable(businessId, name, shortName);

    return this.repository.create({
      businessId,
      name,
      shortName,
      symbol: input.symbol ?? null,
      decimalPlaces: input.decimal_places,
      isSystem: input.is_system,
      isActive: input.is_active,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateUnit(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    unitId: string,
    input: UpdateUnitBody,
  ): Promise<UnitRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, unitId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Unit not found', 404);
    }

    if (existing.is_system && (input.is_system === false || input.name)) {
      throw new AppError(
        'VALIDATION_ERROR',
        'System units cannot be renamed or deactivated',
        422,
      );
    }

    const name = input.name !== undefined ? input.name.trim() : existing.name;
    const shortName =
      input.short_name !== undefined
        ? input.short_name.trim()
        : existing.short_name;

    await this.assertNamesAvailable(
      businessId,
      name,
      shortName,
      unitId,
      input.name !== undefined,
      input.short_name !== undefined,
    );

    const updated = await this.repository.update(businessId, unitId, {
      ...(input.name !== undefined ? { name } : {}),
      ...(input.short_name !== undefined ? { shortName } : {}),
      ...(input.symbol !== undefined ? { symbol: input.symbol ?? null } : {}),
      ...(input.decimal_places !== undefined
        ? { decimalPlaces: input.decimal_places }
        : {}),
      ...(input.is_system !== undefined ? { isSystem: input.is_system } : {}),
      ...(input.is_active !== undefined ? { isActive: input.is_active } : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Unit not found', 404);
    }

    return updated;
  }

  async deleteUnit(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    unitId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findRowById(businessId, unitId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Unit not found', 404);
    }

    if (existing.isSystem) {
      throw new AppError(
        'VALIDATION_ERROR',
        'System units cannot be deleted',
        422,
      );
    }

    const conversionRefs =
      await this.repository.countActiveConversionReferences(businessId, unitId);
    if (conversionRefs > 0) {
      throw new AppError(
        'UNIT_HAS_CONVERSIONS',
        'Cannot delete unit referenced by active conversions',
        422,
      );
    }

    const itemRefs = await this.repository.countActiveItemReferences(
      businessId,
      existing.shortName,
    );
    if (itemRefs > 0) {
      throw new AppError(
        'UNIT_HAS_ITEMS',
        'Cannot delete unit referenced by active items',
        422,
      );
    }

    const deleted = await this.repository.softDelete(
      businessId,
      unitId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Unit not found', 404);
    }
  }

  private async assertNamesAvailable(
    businessId: string,
    name: string,
    shortName: string,
    excludeUnitId?: string,
    checkName = true,
    checkShortName = true,
  ): Promise<void> {
    if (checkName) {
      const nameConflict = await this.repository.findActiveNameConflict(
        businessId,
        name,
        excludeUnitId,
      );
      if (nameConflict) {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          name: ['A unit with this name already exists'],
        });
      }
    }

    if (checkShortName) {
      const shortConflict = await this.repository.findActiveShortNameConflict(
        businessId,
        shortName,
        excludeUnitId,
      );
      if (shortConflict) {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          short_name: ['A unit with this short name already exists'],
        });
      }
    }
  }
}
