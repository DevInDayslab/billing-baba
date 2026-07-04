import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import { normalizeMoney } from './inventory.utils';
import { UnitRepository } from './unit.repository';
import type {
  CreateUnitConversionBody,
  ListUnitConversionsQuery,
  UpdateUnitConversionBody,
} from './unit.schema';
import type { UnitConversionRecordDto } from './unit.types';
import { UnitConversionRepository } from './unit-conversion.repository';

export class UnitConversionService extends InventoryServiceBase {
  private readonly repository: UnitConversionRepository;
  private readonly unitRepository: UnitRepository;

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
    this.repository = new UnitConversionRepository(db);
    this.unitRepository = new UnitRepository(db);
  }

  async listUnitConversions(
    businessId: string,
    accountId: string,
    query: ListUnitConversionsQuery,
  ): Promise<{
    data: UnitConversionRecordDto[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      fromUnitId: query.from_unit_id,
      toUnitId: query.to_unit_id,
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

  async getUnitConversion(
    businessId: string,
    accountId: string,
    conversionId: string,
  ): Promise<UnitConversionRecordDto> {
    await this.assertBusinessAccess(businessId, accountId);

    const conversion = await this.repository.findById(businessId, conversionId);
    if (!conversion) {
      throw new AppError('NOT_FOUND', 'Unit conversion not found', 404);
    }

    return conversion;
  }

  async createUnitConversion(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateUnitConversionBody,
  ): Promise<UnitConversionRecordDto> {
    await this.assertBusinessAccess(businessId, accountId);

    if (input.from_unit_id === input.to_unit_id) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        to_unit_id: ['From and to units must be different'],
      });
    }

    await this.assertUnitsExist(
      businessId,
      input.from_unit_id,
      input.to_unit_id,
    );

    await this.assertPairAvailable(
      businessId,
      input.from_unit_id,
      input.to_unit_id,
    );

    return this.repository.create({
      businessId,
      fromUnitId: input.from_unit_id,
      toUnitId: input.to_unit_id,
      conversionFactor: normalizeMoney(input.conversion_factor),
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateUnitConversion(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    conversionId: string,
    input: UpdateUnitConversionBody,
  ): Promise<UnitConversionRecordDto> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, conversionId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Unit conversion not found', 404);
    }

    const fromUnitId = input.from_unit_id ?? existing.from_unit_id;
    const toUnitId = input.to_unit_id ?? existing.to_unit_id;

    if (fromUnitId === toUnitId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        to_unit_id: ['From and to units must be different'],
      });
    }

    await this.assertUnitsExist(businessId, fromUnitId, toUnitId);

    await this.assertPairAvailable(
      businessId,
      fromUnitId,
      toUnitId,
      conversionId,
    );

    const updated = await this.repository.update(businessId, conversionId, {
      ...(input.from_unit_id !== undefined
        ? { fromUnitId: input.from_unit_id }
        : {}),
      ...(input.to_unit_id !== undefined ? { toUnitId: input.to_unit_id } : {}),
      ...(input.conversion_factor !== undefined
        ? { conversionFactor: normalizeMoney(input.conversion_factor) }
        : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Unit conversion not found', 404);
    }

    return updated;
  }

  async deleteUnitConversion(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    conversionId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, conversionId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Unit conversion not found', 404);
    }

    const deleted = await this.repository.softDelete(
      businessId,
      conversionId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Unit conversion not found', 404);
    }
  }

  private async assertUnitsExist(
    businessId: string,
    fromUnitId: string,
    toUnitId: string,
  ): Promise<void> {
    const from = await this.unitRepository.findRowById(businessId, fromUnitId);
    if (!from) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        from_unit_id: ['From unit not found'],
      });
    }

    const to = await this.unitRepository.findRowById(businessId, toUnitId);
    if (!to) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        to_unit_id: ['To unit not found'],
      });
    }
  }

  private async assertPairAvailable(
    businessId: string,
    fromUnitId: string,
    toUnitId: string,
    excludeConversionId?: string,
  ): Promise<void> {
    const conflictId = await this.repository.findActivePairConflict(
      businessId,
      fromUnitId,
      toUnitId,
      excludeConversionId,
    );

    if (conflictId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        from_unit_id: ['A conversion for this unit pair already exists'],
      });
    }
  }
}
