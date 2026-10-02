import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import type { PricingTier } from '../../shared/pricing/pricing-tier';
import { InventoryServiceBase } from './inventory.base-service';
import { normalizeMoney, parseMoney } from './inventory.utils';
import {
  enrichItemDetailRecord,
  enrichItemListRecord,
  loadStockSummariesForItems,
} from './inventory-item-stock';
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
import { ItemMediaService } from './item-media.service';

export class ItemService extends InventoryServiceBase {
  private readonly repository: ItemRepository;
  private readonly db: NonNullable<ReturnType<typeof getDb>>;
  private readonly media?: ItemMediaService;

  constructor(config?: AppConfig) {
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
    if (config) {
      this.media = new ItemMediaService({
        config,
        itemRepository: this.repository,
      });
    }
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
    const { physicalByItem, reservedByItem } = await loadStockSummariesForItems(
      this.db,
      businessId,
      stockTrackedIds,
    );

    const listData = result.rows.map((row) =>
      enrichItemListRecord(row, physicalByItem, reservedByItem),
    );

    const data = this.media
      ? await Promise.all(
          listData.map(async (item) => ({
            ...item,
            primary_image_url: await this.media!.resolvePrimaryImageUrl(
              businessId,
              accountId,
              item.id,
              item.primary_image_url,
            ),
          })),
        )
      : listData;

    return {
      data,
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
      return this.enrichItemMedia(businessId, accountId, item);
    }

    const { physicalByItem, reservedByItem } = await loadStockSummariesForItems(
      this.db,
      businessId,
      [itemId],
    );

    return this.enrichItemMedia(
      businessId,
      accountId,
      enrichItemDetailRecord(item, physicalByItem, reservedByItem),
    );
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
        shortName: input.short_name?.trim() || null,
        alias: input.alias?.trim() || null,
        searchKeywords: input.search_keywords ?? null,
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
        defaultTaxRate: input.default_tax_rate ?? null,
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

    if (input.alternative_item_ids.length > 0) {
      await this.assertAlternativeItemsValid(
        businessId,
        itemId,
        input.alternative_item_ids,
      );
      await this.repository.replaceAlternatives(
        businessId,
        itemId,
        input.alternative_item_ids,
        userId ?? null,
      );
      return (await this.repository.findById(businessId, itemId)) ?? created;
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
      ...(input.short_name !== undefined
        ? { shortName: input.short_name?.trim() || null }
        : {}),
      ...(input.alias !== undefined
        ? { alias: input.alias?.trim() || null }
        : {}),
      ...(input.search_keywords !== undefined
        ? { searchKeywords: input.search_keywords ?? null }
        : {}),
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
      ...(input.default_tax_rate !== undefined
        ? { defaultTaxRate: input.default_tax_rate ?? null }
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

    if (input.alternative_item_ids !== undefined) {
      await this.assertAlternativeItemsValid(
        businessId,
        itemId,
        input.alternative_item_ids,
      );
      await this.repository.replaceAlternatives(
        businessId,
        itemId,
        input.alternative_item_ids,
        userId ?? null,
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
    // Re-saving the same stock total (common on item edit) is a no-op.
    if (delta === 0) {
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

    const stockQty = await this.repository.getTotalStockQuantity(
      businessId,
      itemId,
    );
    if (stockQty !== 0) {
      throw new AppError(
        'ITEM_HAS_STOCK',
        'Cannot delete item with non-zero stock. Adjust stock to zero first.',
        422,
      );
    }

    const bomUsage = await this.repository.countBomReferences(
      businessId,
      itemId,
    );
    if (bomUsage > 0) {
      throw new AppError(
        'ITEM_USED_IN_BOM',
        'Cannot delete item used as a raw material in manufacturing BOMs',
        422,
      );
    }

    const docUsage = await this.repository.countDocumentLineReferences(
      businessId,
      itemId,
    );
    if (docUsage > 0) {
      throw new AppError(
        'ITEM_HAS_TRANSACTIONS',
        'Cannot delete item referenced by sales or purchase documents',
        422,
      );
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

  private async enrichItemMedia(
    businessId: string,
    accountId: string,
    item: ItemDetailRecord,
  ): Promise<ItemDetailRecord> {
    if (!this.media) return item;

    const [images, primaryUrl] = await Promise.all([
      this.media.enrichItemImages(businessId, accountId, item.images),
      this.media.resolvePrimaryImageUrl(
        businessId,
        accountId,
        item.id,
        item.primary_image_url,
      ),
    ]);

    return {
      ...item,
      images,
      primary_image_url: primaryUrl,
    };
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

  async getAlternativesIndex(
    businessId: string,
    accountId: string,
  ): Promise<Record<string, string[]>> {
    await this.assertBusinessAccess(businessId, accountId);
    return this.repository.loadAlternativesIndex(businessId);
  }

  async listItemAlternatives(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<string[]> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
    return this.repository.listAlternativeIds(businessId, itemId);
  }

  async putItemAlternatives(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    alternativeItemIds: string[],
  ): Promise<ItemDetailRecord> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
    await this.assertAlternativeItemsValid(
      businessId,
      itemId,
      alternativeItemIds,
    );
    await this.repository.replaceAlternatives(
      businessId,
      itemId,
      alternativeItemIds,
      userId ?? null,
    );

    const detail = await this.repository.findById(businessId, itemId);
    if (!detail) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }
    return detail;
  }

  private async assertAlternativeItemsValid(
    businessId: string,
    itemId: string,
    alternativeItemIds: string[],
  ): Promise<void> {
    const uniqueIds = [...new Set(alternativeItemIds)];
    if (uniqueIds.length !== alternativeItemIds.length) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        alternative_item_ids: ['Duplicate alternative items are not allowed'],
      });
    }

    if (uniqueIds.includes(itemId)) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        alternative_item_ids: ['An item cannot be an alternative to itself'],
      });
    }

    if (uniqueIds.length === 0) return;

    const existing = await this.repository.findExistingItemIds(
      businessId,
      uniqueIds,
    );
    const missing = uniqueIds.filter((id) => !existing.has(id));
    if (missing.length > 0) {
      throw new AppError('VALIDATION_ERROR', 'Invalid request body', 400, {
        alternative_item_ids: ['One or more alternative items were not found'],
      });
    }
  }
}
