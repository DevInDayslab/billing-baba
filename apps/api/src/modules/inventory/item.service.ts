import { getDb } from '../../db/client';
import {
  enrichItemDetailRecord,
  enrichItemListRecord,
  loadStockSummariesForItems,
} from './inventory-item-stock';
import { AppError } from '../../shared/errors/app-error';
import type { PricingTier } from '../../shared/pricing/pricing-tier';
import { InventoryServiceBase } from './inventory.base-service';
import { normalizeMoney, parseMoney } from './inventory.utils';
import {
  getDefaultGodown,
  recordMovementAndUpdateStock,
} from './inventory-stock.service';
import { ItemRepository } from './item.repository';
import type {
  CreateItemBody,
  CreateItemImageBody,
  ListItemPriceHistoryQuery,
  ListItemsQuery,
  PutItemTierPricesBody,
  UpdateItemBody,
  UpdateItemImageBody,
} from './item.schema';
import type {
  ItemDetailRecord,
  ItemImageRecord,
  ItemListRecord,
  ItemPriceHistoryRecord,
  ItemTierPriceRecord,
} from './item.types';

export class ItemService extends InventoryServiceBase {
  private readonly repository: ItemRepository;
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
    this.repository = new ItemRepository(db);
  }

  async listItems(
    businessId: string,
    accountId: string,
    query: ListItemsQuery,
  ): Promise<{
    data: ItemListRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);

    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      q: query.q,
      type: query.type,
      categoryId: query.category_id,
      brandId: query.brand_id,
      hsn: query.hsn,
      barcode: query.barcode,
      sort: query.sort,
      order: query.order,
    });

    const stockTrackedIds = result.rows
      .filter((row) => row.has_stock_tracking)
      .map((row) => row.id);
    const { physicalByItem, reservedByItem } =
      await loadStockSummariesForItems(
        this.db,
        businessId,
        stockTrackedIds,
      );

    return {
      data: result.rows.map((row) =>
        enrichItemListRecord(row, physicalByItem, reservedByItem),
      ),
      meta: {
        page: query.page,
        limit: query.limit,
        total: result.total,
      },
    };
  }

  async getItem(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<ItemDetailRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const item = await this.repository.findById(businessId, itemId);
    if (!item) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }

    if (!item.has_stock_tracking) {
      return item;
    }

    const { physicalByItem, reservedByItem } =
      await loadStockSummariesForItems(this.db, businessId, [itemId]);

    return enrichItemDetailRecord(item, physicalByItem, reservedByItem);
  }

  async createItem(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    input: CreateItemBody,
  ): Promise<ItemDetailRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const name = input.name.trim();
    const baseUnit = input.base_unit.trim();
    const hasStockTracking =
      input.item_type === 'service' ? false : input.has_stock_tracking;

    await this.assertBaseUnitValid(businessId, baseUnit);

    if (input.category_id) {
      await this.assertCategoryValid(businessId, input.category_id);
    }

    if (input.brand_id) {
      await this.assertBrandValid(businessId, input.brand_id);
    }

    if (input.barcode) {
      await this.assertBarcodeAvailable(businessId, input.barcode);
    }

    const openingQty = parseMoney(input.opening_quantity ?? '0');
    const openingCost = normalizeMoney(input.opening_cost_per_unit ?? '0');

    if (openingQty > 0 && !hasStockTracking) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        opening_quantity: [
          'Opening quantity is not allowed for items without stock tracking',
        ],
      });
    }

    let openingGodownId = input.opening_godown_id;
    if (openingQty > 0) {
      if (openingGodownId) {
        await this.assertGodownValid(businessId, openingGodownId);
      } else {
        const defaultGodown = await getDefaultGodown(this.db, businessId);
        openingGodownId = defaultGodown.id;
      }
    }

    if (input.location) {
      await this.assertGodownValid(businessId, input.location.godown_id);
    }

    const tierPrices = (input.tier_prices ?? []).map((tier) => ({
      pricingTier: tier.pricing_tier,
      price: normalizeMoney(tier.price),
    }));

    const itemId = await this.repository.runTransaction(async (tx) => {
      const item = await this.repository.create(tx, {
        businessId,
        name,
        description: input.description ?? null,
        itemType: input.item_type,
        hasStockTracking,
        categoryId: input.category_id ?? null,
        brandId: input.brand_id ?? null,
        hsnCode: input.hsn_code ?? null,
        barcode: input.barcode ?? null,
        baseUnit,
        salePrice: normalizeMoney(input.sale_price),
        purchasePrice: normalizeMoney(input.purchase_price),
        mrp: input.mrp ?? null,
        marketPrice: input.market_price ?? null,
        reorderLevel: input.reorder_level ?? null,
        primaryImageUrl: input.primary_image_url ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      });

      await this.repository.insertTierPrices(
        tx,
        businessId,
        item.id,
        tierPrices,
        userId ?? null,
      );

      await this.repository.insertPriceHistory(tx, businessId, item.id, {
        price: normalizeMoney(input.sale_price),
        pricingTier: 'tier_1',
        changedBy: userId ?? null,
      });

      for (const tier of tierPrices) {
        await this.repository.insertPriceHistory(tx, businessId, item.id, {
          price: tier.price,
          pricingTier: tier.pricingTier,
          changedBy: userId ?? null,
        });
      }

      if (input.location) {
        await this.repository.insertLocation(
          tx,
          businessId,
          item.id,
          {
            godownId: input.location.godown_id,
            rack: input.location.rack ?? null,
            shelf: input.location.shelf ?? null,
          },
          userId ?? null,
        );
      }

      if (openingQty > 0 && openingGodownId) {
        await recordMovementAndUpdateStock(this.db, tx, {
          businessId,
          itemId: item.id,
          godownId: openingGodownId,
          movementType: 'opening',
          quantityDelta: normalizeMoney(openingQty),
          costPerUnit: openingCost,
          unit: baseUnit,
          referenceType: 'items',
          referenceId: item.id,
          createdBy: userId ?? null,
        });
      }

      return item.id;
    });

    const created = await this.repository.findById(businessId, itemId);
    if (!created) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }

    return created;
  }

  async updateItem(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    input: UpdateItemBody,
  ): Promise<ItemDetailRecord> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findRowById(businessId, itemId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }

    const itemType = input.item_type ?? existing.itemType;
    const hasStockTracking =
      itemType === 'service'
        ? false
        : (input.has_stock_tracking ?? existing.hasStockTracking);

    if (input.base_unit !== undefined) {
      await this.assertBaseUnitValid(businessId, input.base_unit.trim());
    }

    if (input.category_id) {
      await this.assertCategoryValid(businessId, input.category_id);
    }

    if (input.brand_id) {
      await this.assertBrandValid(businessId, input.brand_id);
    }

    if (input.barcode) {
      await this.assertBarcodeAvailable(businessId, input.barcode, itemId);
    }

    const updated = await this.repository.update(businessId, itemId, {
      ...(input.name !== undefined ? { name: input.name.trim() } : {}),
      ...(input.description !== undefined
        ? { description: input.description }
        : {}),
      itemType,
      hasStockTracking,
      ...(input.category_id !== undefined
        ? { categoryId: input.category_id }
        : {}),
      ...(input.brand_id !== undefined ? { brandId: input.brand_id } : {}),
      ...(input.hsn_code !== undefined ? { hsnCode: input.hsn_code } : {}),
      ...(input.barcode !== undefined ? { barcode: input.barcode } : {}),
      ...(input.base_unit !== undefined
        ? { baseUnit: input.base_unit.trim() }
        : {}),
      ...(input.sale_price !== undefined
        ? { salePrice: normalizeMoney(input.sale_price) }
        : {}),
      ...(input.purchase_price !== undefined
        ? { purchasePrice: normalizeMoney(input.purchase_price) }
        : {}),
      ...(input.mrp !== undefined ? { mrp: input.mrp } : {}),
      ...(input.market_price !== undefined
        ? { marketPrice: input.market_price }
        : {}),
      ...(input.reorder_level !== undefined
        ? { reorderLevel: input.reorder_level }
        : {}),
      ...(input.primary_image_url !== undefined
        ? { primaryImageUrl: input.primary_image_url }
        : {}),
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }

    if (input.tier_prices !== undefined) {
      await this.syncItemTierPrices(
        businessId,
        itemId,
        userId,
        input.tier_prices.map((tier) => ({
          pricingTier: tier.pricing_tier,
          price: normalizeMoney(tier.price),
        })),
      );
    }

    if (
      input.sale_price !== undefined &&
      normalizeMoney(input.sale_price) !== existing.salePrice
    ) {
      await this.repository.insertPriceHistory(this.db, businessId, itemId, {
        price: normalizeMoney(input.sale_price),
        pricingTier: 'tier_1',
        changedBy: userId ?? null,
      });
    }

    if (input.opening_quantity !== undefined) {
      await this.applyOpeningStockChange(
        businessId,
        itemId,
        userId,
        hasStockTracking,
        {
          openingQuantity: input.opening_quantity,
          openingCostPerUnit: input.opening_cost_per_unit,
          openingGodownId: input.opening_godown_id,
          location: input.location,
        },
      );
    }

    const detail = await this.repository.findById(businessId, itemId);
    if (!detail) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }

    return detail;
  }

  private async applyOpeningStockChange(
    businessId: string,
    itemId: string,
    userId: string | undefined,
    hasStockTracking: boolean,
    input: {
      openingQuantity?: string;
      openingCostPerUnit?: string;
      openingGodownId?: string;
      location?: {
        godown_id: string;
        rack?: string;
        shelf?: string;
      };
    },
  ): Promise<void> {
    const openingQty = parseMoney(input.openingQuantity ?? '0');
    const openingCost = normalizeMoney(input.openingCostPerUnit ?? '0');

    if (openingQty > 0 && !hasStockTracking) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        opening_quantity: [
          'Opening quantity is not allowed for items without stock tracking',
        ],
      });
    }

    if (input.location) {
      await this.assertGodownValid(businessId, input.location.godown_id);
      await this.repository.runTransaction(async (tx) => {
        const hasLocation = await this.repository.hasItemLocation(
          tx,
          businessId,
          itemId,
          input.location!.godown_id,
        );
        if (!hasLocation) {
          await this.repository.insertLocation(
            tx,
            businessId,
            itemId,
            {
              godownId: input.location!.godown_id,
              rack: input.location!.rack ?? null,
              shelf: input.location!.shelf ?? null,
            },
            userId ?? null,
          );
        }
      });
    }

    if (openingQty <= 0) {
      return;
    }

    const hasOtherMovements = await this.repository.hasNonOpeningMovements(
      businessId,
      itemId,
    );
    if (hasOtherMovements) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        opening_quantity: [
          'Opening stock cannot be changed after other inventory transactions exist. Use Adjust Stock instead.',
        ],
      });
    }

    let openingGodownId = input.openingGodownId;
    if (openingGodownId) {
      await this.assertGodownValid(businessId, openingGodownId);
    } else {
      const defaultGodown = await getDefaultGodown(this.db, businessId);
      openingGodownId = defaultGodown.id;
    }

    const currentStock = await this.repository.getTotalStockQuantity(
      businessId,
      itemId,
    );
    const delta = openingQty - currentStock;
    if (delta === 0) {
      return;
    }

    const itemRow = await this.repository.findRowById(businessId, itemId);
    const baseUnit = itemRow?.baseUnit ?? null;

    await this.repository.runTransaction(async (tx) => {
      const movementType =
        currentStock === 0 && delta > 0 ? 'opening' : 'adjustment';

      await recordMovementAndUpdateStock(this.db, tx, {
        businessId,
        itemId,
        godownId: openingGodownId!,
        movementType,
        quantityDelta: normalizeMoney(delta),
        costPerUnit: delta > 0 ? openingCost : null,
        unit: baseUnit,
        referenceType: 'items',
        referenceId: itemId,
        createdBy: userId ?? null,
      });
    });
  }

  async deleteItem(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findRowById(businessId, itemId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }

    const deleted = await this.repository.softDelete(
      businessId,
      itemId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }
  }

  async listItemImages(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<ItemImageRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
    return this.repository.listImages(businessId, itemId);
  }

  async addItemImage(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    input: CreateItemImageBody,
  ): Promise<ItemImageRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);

    return this.repository.addImage(businessId, itemId, {
      imageUrl: input.image_url,
      sortOrder: input.sort_order,
      isPrimary: input.is_primary,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async updateItemImage(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    imageId: string,
    input: UpdateItemImageBody,
  ): Promise<ItemImageRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);

    const updated = await this.repository.updateImage(
      businessId,
      itemId,
      imageId,
      {
        ...(input.image_url !== undefined ? { imageUrl: input.image_url } : {}),
        ...(input.sort_order !== undefined
          ? { sortOrder: input.sort_order }
          : {}),
        ...(input.is_primary !== undefined
          ? { isPrimary: input.is_primary }
          : {}),
        updatedBy: userId ?? null,
      },
    );

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Item image not found', 404);
    }

    return updated;
  }

  async deleteItemImage(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    imageId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);

    const deleted = await this.repository.softDeleteImage(
      businessId,
      itemId,
      imageId,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Item image not found', 404);
    }
  }

  async getItemTierPrices(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<ItemTierPriceRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
    return this.repository.getTierPrices(businessId, itemId);
  }

  async putItemTierPrices(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    input: PutItemTierPricesBody,
  ): Promise<ItemTierPriceRecord[]> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);

    const tierPrices = input.tier_prices.map((tier) => ({
      pricingTier: tier.pricing_tier,
      price: normalizeMoney(tier.price),
    }));

    return this.syncItemTierPrices(businessId, itemId, userId, tierPrices);
  }

  async deleteItemTierPrice(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    pricingTier: PricingTier,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);

    const deleted = await this.repository.deleteTierPrice(
      businessId,
      itemId,
      pricingTier,
      userId ?? null,
    );

    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Tier price not found', 404);
    }
  }

  async listItemPriceHistory(
    businessId: string,
    accountId: string,
    itemId: string,
    query: ListItemPriceHistoryQuery,
  ): Promise<{
    data: ItemPriceHistoryRecord[];
    meta: { page: number; limit: number; total: number };
  }> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);

    const result = await this.repository.listPriceHistory(
      businessId,
      itemId,
      query.page,
      query.limit,
    );

    return {
      data: result.rows,
      meta: {
        page: query.page,
        limit: query.limit,
        total: result.total,
      },
    };
  }

  private async syncItemTierPrices(
    businessId: string,
    itemId: string,
    userId: string | undefined,
    tierPrices: { pricingTier: PricingTier; price: string }[],
  ): Promise<ItemTierPriceRecord[]> {
    const existing = await this.repository.getTierPrices(businessId, itemId);
    const result = await this.repository.replaceTierPrices(
      businessId,
      itemId,
      tierPrices,
      userId ?? null,
    );

    for (const tier of tierPrices) {
      const previous = existing.find(
        (entry) => entry.pricing_tier === tier.pricingTier,
      );
      if (!previous || previous.price !== tier.price) {
        await this.repository.insertPriceHistory(this.db, businessId, itemId, {
          price: tier.price,
          pricingTier: tier.pricingTier,
          changedBy: userId ?? null,
        });
      }
    }

    return result;
  }

  private async assertItemExists(
    businessId: string,
    itemId: string,
  ): Promise<void> {
    const item = await this.repository.findRowById(businessId, itemId);
    if (!item) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }
  }

  private async assertBaseUnitValid(
    businessId: string,
    shortName: string,
  ): Promise<void> {
    const exists = await this.repository.unitShortNameExists(
      businessId,
      shortName,
    );
    if (!exists) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        base_unit: ['Base unit must match an existing unit short name'],
      });
    }
  }

  private async assertCategoryValid(
    businessId: string,
    categoryId: string,
  ): Promise<void> {
    const exists = await this.repository.categoryExists(businessId, categoryId);
    if (!exists) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        category_id: ['Category not found'],
      });
    }
  }

  private async assertBrandValid(
    businessId: string,
    brandId: string,
  ): Promise<void> {
    const exists = await this.repository.brandExists(businessId, brandId);
    if (!exists) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        brand_id: ['Brand not found'],
      });
    }
  }

  private async assertGodownValid(
    businessId: string,
    godownId: string,
  ): Promise<void> {
    const exists = await this.repository.godownExists(businessId, godownId);
    if (!exists) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        godown_id: ['Godown not found'],
      });
    }
  }

  private async assertBarcodeAvailable(
    businessId: string,
    barcode: string,
    excludeItemId?: string,
  ): Promise<void> {
    const conflictId = await this.repository.findActiveBarcodeConflict(
      businessId,
      barcode,
      excludeItemId,
    );

    if (conflictId) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        barcode: ['An item with this barcode already exists'],
      });
    }
  }
}
