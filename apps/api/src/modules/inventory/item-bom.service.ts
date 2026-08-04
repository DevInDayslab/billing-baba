import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { getDb } from '../../db/client';
import { items } from '../../db/schema/inventory/tables';
import { AppError } from '../../shared/errors/app-error';
import { InventoryServiceBase } from './inventory.base-service';
import { ItemBomRepository } from './item-bom.repository';
import type { ReplaceItemBomBody } from './item-bom.schema';
import type { ItemBomRecord } from './item-bom.types';

export class ItemBomService extends InventoryServiceBase {
  private readonly repository: ItemBomRepository;
  private readonly db: Database;

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
    this.repository = new ItemBomRepository(db);
  }

  async getBom(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<ItemBomRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
    return this.repository.getByItemId(businessId, itemId);
  }

  async replaceBom(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    input: ReplaceItemBomBody,
  ): Promise<ItemBomRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);

    const rawItemIds = input.materials.map((material) => material.raw_item_id);
    if (rawItemIds.includes(itemId)) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        materials: ['Finished item cannot be used as its own raw material'],
      });
    }

    await this.assertNoCircularBom(businessId, itemId, rawItemIds);

    if (rawItemIds.length > 0) {
      const validItemIds = await this.repository.findActiveItemIds(
        businessId,
        rawItemIds,
      );
      const invalidIds = rawItemIds.filter((id) => !validItemIds.has(id));
      if (invalidIds.length > 0) {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          materials: ['One or more raw item IDs are invalid'],
        });
      }
    }

    const unitIds = input.materials.map((material) => material.unit_id);
    if (unitIds.length > 0) {
      const validUnitIds = await this.repository.findActiveUnitIds(
        businessId,
        unitIds,
      );
      const invalidIds = unitIds.filter((id) => !validUnitIds.has(id));
      if (invalidIds.length > 0) {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          materials: ['One or more unit IDs are invalid'],
        });
      }
    }

    return this.repository.replaceBom({
      businessId,
      itemId,
      materials: input.materials.map((material, index) => ({
        rawItemId: material.raw_item_id,
        qty: material.qty,
        unitId: material.unit_id,
        purchasePrice: material.purchase_price ?? '0',
        sortOrder: material.sort_order ?? index,
      })),
      costs: input.costs.map((cost, index) => ({
        id: cost.id,
        description: cost.description,
        amount: cost.amount,
        sortOrder: cost.sort_order ?? index,
      })),
      updatedBy: userId ?? null,
    });
  }

  private async assertNoCircularBom(
    businessId: string,
    finishedItemId: string,
    rawItemIds: string[],
  ): Promise<void> {
    if (rawItemIds.length === 0) return;

    const visiting = new Set<string>([finishedItemId]);
    const queue = [...rawItemIds];

    while (queue.length > 0) {
      const current = queue.shift()!;
      if (visiting.has(current)) {
        throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
          materials: ['Circular BOM detected'],
        });
      }
      visiting.add(current);

      const childMaterials = await this.repository.listRawItemIdsForItem(
        businessId,
        current,
      );
      for (const childId of childMaterials) {
        if (childId === finishedItemId) {
          throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
            materials: ['Circular BOM detected'],
          });
        }
        if (!visiting.has(childId)) {
          queue.push(childId);
        }
      }
    }
  }

  private async assertItemExists(
    businessId: string,
    itemId: string,
  ): Promise<void> {
    const [item] = await this.db
      .select({ id: items.id })
      .from(items)
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .limit(1);

    if (!item) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }
  }
}
