import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import { normalizeMoney } from './inventory.utils';
import { recordMovementAndUpdateStock } from './inventory-stock.service';
import { ItemRepository } from './item.repository';
import { MovementRepository } from './movement.repository';
import type { CreateMovementBody, ListMovementsQuery } from './movement.schema';
import type { MovementRecord } from './movement.types';

export class MovementService extends InventoryServiceBase {
  private readonly repository: MovementRepository;
  private readonly itemRepository: ItemRepository;
  private readonly db: NonNullable<ReturnType<typeof getDb>>;

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
    this.repository = new MovementRepository(db);
    this.itemRepository = new ItemRepository(db);
  }

  async listMovements(
    businessId: string,
    accountId: string,
    query: ListMovementsQuery,
  ): Promise<{
    data: MovementRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      itemId: query.item_id,
      godownId: query.godown_id,
      movementType: query.movement_type,
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

  async getMovement(
    businessId: string,
    accountId: string,
    movementId: string,
  ): Promise<MovementRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const movement = await this.repository.findById(businessId, movementId);
    if (!movement) {
      throw new AppError('NOT_FOUND', 'Movement not found', 404);
    }

    return movement;
  }

  async createMovement(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateMovementBody,
  ): Promise<MovementRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const item = await this.itemRepository.findRowById(
      businessId,
      input.item_id,
    );
    if (!item) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        item_id: ['Item not found'],
      });
    }

    if (!item.hasStockTracking) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        item_id: ['Stock movements are not allowed for this item'],
      });
    }

    const godownExists = await this.itemRepository.godownExists(
      businessId,
      input.godown_id,
    );
    if (!godownExists) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        godown_id: ['Godown not found'],
      });
    }

    const movementId = await this.repository.runTransaction(async (tx) => {
      const result = await recordMovementAndUpdateStock(this.db, tx, {
        businessId,
        itemId: input.item_id,
        godownId: input.godown_id,
        movementType: input.movement_type,
        quantityDelta: normalizeMoney(input.quantity_delta),
        costPerUnit: input.cost_per_unit ?? null,
        unit: item.baseUnit,
        referenceId: input.reference_id ?? null,
        referenceType: input.reference_type ?? null,
        createdBy: userId ?? null,
      });

      return result.movementId;
    });

    const movement = await this.repository.findById(businessId, movementId);
    if (!movement) {
      throw new AppError('NOT_FOUND', 'Movement not found', 404);
    }

    return movement;
  }
}
