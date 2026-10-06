import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import { ItemRepository } from './item.repository';
import { ItemLocationRepository } from './item-location.repository';
import type {
  CreateItemLocationBody,
  ListItemLocationHistoryQuery,
  ListItemLocationsQuery,
  UpdateItemLocationBody,
} from './item-location.schema';
import type { ItemLocationRecord } from './item-location.types';
import { ItemLocationHistoryRepository } from './item-location-history.repository';
import type { ItemLocationHistoryRecord } from './item-location-history.types';

export class ItemLocationService extends InventoryServiceBase {
  private readonly repository: ItemLocationRepository;
  private readonly historyRepository: ItemLocationHistoryRepository;
  private readonly itemRepository: ItemRepository;

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
    this.repository = new ItemLocationRepository(db);
    this.historyRepository = new ItemLocationHistoryRepository(db);
    this.itemRepository = new ItemRepository(db);
  }

  async listItemLocations(
    businessId: string,
    accountId: string,
    query: ListItemLocationsQuery,
  ): Promise<{
    data: ItemLocationRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      itemId: query.item_id,
      godownId: query.godown_id,
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

  async listItemLocationHistory(
    businessId: string,
    accountId: string,
    locationId: string,
    query: ListItemLocationHistoryQuery,
  ): Promise<{
    data: ItemLocationHistoryRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const location = await this.repository.findById(businessId, locationId);
    if (!location) {
      throw new AppError('NOT_FOUND', 'Item location not found', 404);
    }

    const result = await this.historyRepository.listByLocation({
      businessId,
      itemLocationId: locationId,
      page: query.page,
      limit: query.limit,
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

  async getItemLocation(
    businessId: string,
    accountId: string,
    locationId: string,
  ): Promise<ItemLocationRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const location = await this.repository.findById(businessId, locationId);
    if (!location) {
      throw new AppError('NOT_FOUND', 'Item location not found', 404);
    }

    return location;
  }

  async createItemLocation(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateItemLocationBody,
  ): Promise<ItemLocationRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    await this.assertItemExists(businessId, input.item_id);
    await this.assertGodownExists(businessId, input.godown_id);

    const created = await this.repository.create({
      businessId,
      itemId: input.item_id,
      godownId: input.godown_id,
      rack: input.rack ?? null,
      shelf: input.shelf ?? null,
      photoUrl: input.photo_url ?? null,
      photoTakenAt: input.photo_url ? new Date() : null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });

    await this.recordHistory({
      businessId,
      location: created,
      employeeLabel: input.employee_label ?? null,
      changedBy: userId ?? null,
    });

    return created;
  }

  async updateItemLocation(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    locationId: string,
    input: UpdateItemLocationBody,
  ): Promise<ItemLocationRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, locationId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Item location not found', 404);
    }

    if (input.godown_id) {
      await this.assertGodownExists(businessId, input.godown_id);
    }

    const photoTakenAt =
      input.photo_url !== undefined && input.photo_url !== null
        ? new Date()
        : undefined;

    const updated = await this.repository.update(businessId, locationId, {
      ...(input.godown_id !== undefined ? { godownId: input.godown_id } : {}),
      ...(input.rack !== undefined ? { rack: input.rack } : {}),
      ...(input.shelf !== undefined ? { shelf: input.shelf } : {}),
      ...(input.photo_url !== undefined ? { photoUrl: input.photo_url } : {}),
      ...(photoTakenAt !== undefined ? { photoTakenAt } : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Item location not found', 404);
    }

    const rackChanged =
      input.rack !== undefined && input.rack !== existing.rack;
    const shelfChanged =
      input.shelf !== undefined && input.shelf !== existing.shelf;
    const godownChanged =
      input.godown_id !== undefined && input.godown_id !== existing.godown_id;

    if (
      rackChanged ||
      shelfChanged ||
      godownChanged ||
      input.employee_label !== undefined
    ) {
      await this.recordHistory({
        businessId,
        location: updated,
        employeeLabel: input.employee_label ?? null,
        changedBy: userId ?? null,
        photoUrl: updated.photo_url,
      });
    }

    return updated;
  }

  async recordRackPhotoHistory(
    businessId: string,
    locationId: string,
    input: {
      photoUrl: string;
      photoMediaAssetId: string;
      employeeLabel?: string | null;
      changedBy?: string | null;
    },
  ): Promise<void> {
    const location = await this.repository.findById(businessId, locationId);
    if (!location) return;

    await this.historyRepository.insert({
      businessId,
      itemLocationId: locationId,
      itemId: location.item_id,
      rack: location.rack,
      shelf: location.shelf,
      photoUrl: input.photoUrl,
      photoMediaAssetId: input.photoMediaAssetId,
      employeeLabel: input.employeeLabel ?? null,
      changedBy: input.changedBy ?? null,
    });
  }

  async deleteItemLocation(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    locationId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, locationId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Item location not found', 404);
    }

    const deleted = await this.repository.softDelete(
      businessId,
      locationId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Item location not found', 404);
    }
  }

  private async recordHistory(params: {
    businessId: string;
    location: ItemLocationRecord;
    employeeLabel?: string | null;
    changedBy?: string | null;
    photoUrl?: string | null;
    photoMediaAssetId?: string | null;
  }): Promise<void> {
    await this.historyRepository.insert({
      businessId: params.businessId,
      itemLocationId: params.location.id,
      itemId: params.location.item_id,
      rack: params.location.rack,
      shelf: params.location.shelf,
      photoUrl: params.photoUrl ?? params.location.photo_url,
      photoMediaAssetId: params.photoMediaAssetId ?? null,
      employeeLabel: params.employeeLabel ?? null,
      changedBy: params.changedBy ?? null,
    });
  }

  private async assertItemExists(
    businessId: string,
    itemId: string,
  ): Promise<void> {
    const item = await this.itemRepository.findRowById(businessId, itemId);
    if (!item) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        item_id: ['Item not found'],
      });
    }
  }

  private async assertGodownExists(
    businessId: string,
    godownId: string,
  ): Promise<void> {
    const exists = await this.itemRepository.godownExists(businessId, godownId);
    if (!exists) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        godown_id: ['Godown not found'],
      });
    }
  }
}
