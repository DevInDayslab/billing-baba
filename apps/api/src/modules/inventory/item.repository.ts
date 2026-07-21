import {
  and,
  asc,
  count,
  desc,
  eq,
  ilike,
  ne,
  notInArray,
  or,
  sql,
} from 'drizzle-orm';
import type { Database } from '../../db/client';
import {
  brands,
  categories,
  godowns,
  inventoryMovements,
  itemImages,
  itemLocations,
  itemPriceHistory,
  items,
  itemTierPrices,
  stockLevels,
  unitDefinitions,
} from '../../db/schema/inventory/tables';
import type { PricingTier } from '../../shared/pricing/pricing-tier';
import { parseMoney } from './inventory.utils';
import {
  toItemDetailRecord,
  toItemImageRecord,
  toItemListRecord,
  toItemPriceHistoryRecord,
  toItemTierPriceRecord,
} from './item.mapper';
import type {
  CreateItemImageInput,
  CreateItemLocationInput,
  CreateItemTierPriceInput,
  ItemDetailRecord,
  ItemImageRecord,
  ItemInsertValues,
  ItemListRecord,
  ItemPriceHistoryRecord,
  ItemRow,
  ItemTierPriceRecord,
  ItemUpdateValues,
  ListItemsParams,
  OpeningStockGodownSummary,
  RecordPriceHistoryInput,
  UpdateItemImageInput,
} from './item.types';

type DbTransaction = Parameters<Parameters<Database['transaction']>[0]>[0];
type DbOrTransaction = Database | DbTransaction;

export class ItemRepository {
  constructor(private readonly db: Database) {}

  private itemSelectShape() {
    return {
      id: items.id,
      name: items.name,
      description: items.description,
      itemType: items.itemType,
      hasStockTracking: items.hasStockTracking,
      categoryId: items.categoryId,
      categoryName: categories.name,
      brandId: items.brandId,
      brandName: brands.name,
      hsnCode: items.hsnCode,
      barcode: items.barcode,
      baseUnit: items.baseUnit,
      baseUnitId: unitDefinitions.id,
      baseUnitName: unitDefinitions.name,
      baseUnitSymbol: unitDefinitions.symbol,
      salePrice: items.salePrice,
      purchasePrice: items.purchasePrice,
      mrp: items.mrp,
      marketPrice: items.marketPrice,
      reorderLevel: items.reorderLevel,
      primaryImageUrl: items.primaryImageUrl,
      createdAt: items.createdAt,
      updatedAt: items.updatedAt,
    };
  }

  private itemJoins() {
    return {
      categories: and(
        eq(items.categoryId, categories.id),
        eq(categories.isDeleted, false),
      ),
      brands: and(eq(items.brandId, brands.id), eq(brands.isDeleted, false)),
      unitDefinitions: and(
        eq(unitDefinitions.businessId, items.businessId),
        eq(unitDefinitions.isDeleted, false),
        sql`lower(${unitDefinitions.shortName}) = lower(${items.baseUnit})`,
      ),
    };
  }

  async list(params: ListItemsParams): Promise<{
    rows: ItemListRecord[];
    total: number;
  }> {
    const filters = [
      eq(items.businessId, params.businessId),
      eq(items.isDeleted, false),
    ];

    if (params.q) {
      const pattern = `%${params.q}%`;
      const search = or(
        ilike(items.name, pattern),
        ilike(items.barcode, pattern),
        ilike(items.hsnCode, pattern),
      );
      if (search) filters.push(search);
    }

    if (params.type) {
      filters.push(eq(items.itemType, params.type));
    }

    if (params.categoryId) {
      filters.push(eq(items.categoryId, params.categoryId));
    }

    if (params.brandId) {
      filters.push(eq(items.brandId, params.brandId));
    }

    if (params.hsn) {
      filters.push(ilike(items.hsnCode, `%${params.hsn}%`));
    }

    if (params.barcode) {
      filters.push(eq(items.barcode, params.barcode));
    }

    const whereClause = and(...filters);
    const joins = this.itemJoins();

    const countResult = await this.db
      .select({ total: count() })
      .from(items)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);

    const sortColumn =
      params.sort === 'created_at' ? items.createdAt : items.name;
    const orderBy =
      params.order === 'desc' ? desc(sortColumn) : asc(sortColumn);
    const offset = (params.page - 1) * params.limit;

    const rows = await this.db
      .select(this.itemSelectShape())
      .from(items)
      .leftJoin(categories, joins.categories)
      .leftJoin(brands, joins.brands)
      .leftJoin(unitDefinitions, joins.unitDefinitions)
      .where(whereClause)
      .orderBy(orderBy)
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map((row) => toItemListRecord(row as ItemRow)),
      total,
    };
  }

  async findById(
    businessId: string,
    itemId: string,
  ): Promise<ItemDetailRecord | null> {
    const joins = this.itemJoins();

    const [row] = await this.db
      .select(this.itemSelectShape())
      .from(items)
      .leftJoin(categories, joins.categories)
      .leftJoin(brands, joins.brands)
      .leftJoin(unitDefinitions, joins.unitDefinitions)
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) {
      return null;
    }

    const [tierPrices, images, locations, openingStock] = await Promise.all([
      this.loadTierPrices(businessId, itemId),
      this.loadImages(businessId, itemId),
      this.loadLocations(businessId, itemId),
      this.loadOpeningStock(businessId, itemId),
    ]);

    return toItemDetailRecord(
      row as ItemRow,
      tierPrices,
      images,
      locations,
      openingStock,
    );
  }

  async findRowById(
    businessId: string,
    itemId: string,
  ): Promise<ItemRow | null> {
    const joins = this.itemJoins();

    const [row] = await this.db
      .select(this.itemSelectShape())
      .from(items)
      .leftJoin(categories, joins.categories)
      .leftJoin(brands, joins.brands)
      .leftJoin(unitDefinitions, joins.unitDefinitions)
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? (row as ItemRow) : null;
  }

  async findActiveBarcodeConflict(
    businessId: string,
    barcode: string,
    excludeItemId?: string,
  ): Promise<string | null> {
    const conditions = [
      eq(items.businessId, businessId),
      eq(items.isDeleted, false),
      eq(items.barcode, barcode),
    ];

    if (excludeItemId) {
      conditions.push(ne(items.id, excludeItemId));
    }

    const [row] = await this.db
      .select({ id: items.id })
      .from(items)
      .where(and(...conditions))
      .limit(1);

    return row?.id ?? null;
  }

  async unitShortNameExists(
    businessId: string,
    shortName: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: unitDefinitions.id })
      .from(unitDefinitions)
      .where(
        and(
          eq(unitDefinitions.businessId, businessId),
          eq(unitDefinitions.isDeleted, false),
          eq(unitDefinitions.isActive, true),
          sql`lower(${unitDefinitions.shortName}) = lower(${shortName})`,
        ),
      )
      .limit(1);

    return Boolean(row);
  }

  async categoryExists(
    businessId: string,
    categoryId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ id: categories.id })
      .from(categories)
      .where(
        and(
          eq(categories.id, categoryId),
          eq(categories.businessId, businessId),
          eq(categories.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(row);
  }

  async brandExists(businessId: string, brandId: string): Promise<boolean> {
    const [row] = await this.db
      .select({ id: brands.id })
      .from(brands)
      .where(
        and(
          eq(brands.id, brandId),
          eq(brands.businessId, businessId),
          eq(brands.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(row);
  }

  async godownExists(businessId: string, godownId: string): Promise<boolean> {
    const [row] = await this.db
      .select({ id: godowns.id })
      .from(godowns)
      .where(
        and(
          eq(godowns.id, godownId),
          eq(godowns.businessId, businessId),
          eq(godowns.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(row);
  }

  async create(tx: DbTransaction, values: ItemInsertValues): Promise<ItemRow> {
    const [row] = await tx
      .insert(items)
      .values({
        businessId: values.businessId,
        name: values.name,
        description: values.description ?? null,
        itemType: values.itemType,
        hasStockTracking: values.hasStockTracking,
        categoryId: values.categoryId ?? null,
        brandId: values.brandId ?? null,
        hsnCode: values.hsnCode ?? null,
        barcode: values.barcode ?? null,
        baseUnit: values.baseUnit,
        salePrice: values.salePrice,
        purchasePrice: values.purchasePrice,
        mrp: values.mrp ?? null,
        marketPrice: values.marketPrice ?? null,
        reorderLevel: values.reorderLevel ?? null,
        primaryImageUrl: values.primaryImageUrl ?? null,
        createdBy: values.createdBy ?? null,
        updatedBy: values.updatedBy ?? null,
      })
      .returning({
        id: items.id,
        name: items.name,
        description: items.description,
        itemType: items.itemType,
        hasStockTracking: items.hasStockTracking,
        categoryId: items.categoryId,
        categoryName: sql<string | null>`null`,
        brandId: items.brandId,
        brandName: sql<string | null>`null`,
        hsnCode: items.hsnCode,
        barcode: items.barcode,
        baseUnit: items.baseUnit,
        baseUnitId: sql<string | null>`null`,
        baseUnitName: sql<string | null>`null`,
        baseUnitSymbol: sql<string | null>`null`,
        salePrice: items.salePrice,
        purchasePrice: items.purchasePrice,
        mrp: items.mrp,
        marketPrice: items.marketPrice,
        reorderLevel: items.reorderLevel,
        primaryImageUrl: items.primaryImageUrl,
        createdAt: items.createdAt,
        updatedAt: items.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to create item');
    }

    return row as ItemRow;
  }

  async insertTierPrices(
    tx: DbTransaction,
    businessId: string,
    itemId: string,
    tierPrices: CreateItemTierPriceInput[],
    userId?: string | null,
  ): Promise<void> {
    if (tierPrices.length === 0) {
      return;
    }

    await tx.insert(itemTierPrices).values(
      tierPrices.map((tier) => ({
        businessId,
        itemId,
        pricingTier: tier.pricingTier,
        price: tier.price,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      })),
    );
  }

  async insertLocation(
    tx: DbTransaction,
    businessId: string,
    itemId: string,
    location: CreateItemLocationInput,
    userId?: string | null,
  ): Promise<void> {
    await tx.insert(itemLocations).values({
      businessId,
      itemId,
      godownId: location.godownId,
      rack: location.rack ?? null,
      shelf: location.shelf ?? null,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });
  }

  async hasItemLocation(
    tx: DbTransaction,
    businessId: string,
    itemId: string,
    godownId: string,
  ): Promise<boolean> {
    const [row] = await tx
      .select({ id: itemLocations.id })
      .from(itemLocations)
      .where(
        and(
          eq(itemLocations.businessId, businessId),
          eq(itemLocations.itemId, itemId),
          eq(itemLocations.godownId, godownId),
          eq(itemLocations.isDeleted, false),
        ),
      )
      .limit(1);

    return Boolean(row);
  }

  async insertPriceHistory(
    dbOrTx: DbOrTransaction,
    businessId: string,
    itemId: string,
    input: RecordPriceHistoryInput,
  ): Promise<void> {
    await dbOrTx.insert(itemPriceHistory).values({
      businessId,
      itemId,
      price: input.price,
      pricingTier: input.pricingTier ?? null,
      changedBy: input.changedBy ?? null,
    });
  }

  async update(
    businessId: string,
    itemId: string,
    values: ItemUpdateValues,
  ): Promise<ItemRow | null> {
    const [row] = await this.db
      .update(items)
      .set({
        ...(values.name !== undefined ? { name: values.name } : {}),
        ...(values.description !== undefined
          ? { description: values.description }
          : {}),
        ...(values.itemType !== undefined ? { itemType: values.itemType } : {}),
        ...(values.hasStockTracking !== undefined
          ? { hasStockTracking: values.hasStockTracking }
          : {}),
        ...(values.categoryId !== undefined
          ? { categoryId: values.categoryId }
          : {}),
        ...(values.brandId !== undefined ? { brandId: values.brandId } : {}),
        ...(values.hsnCode !== undefined ? { hsnCode: values.hsnCode } : {}),
        ...(values.barcode !== undefined ? { barcode: values.barcode } : {}),
        ...(values.baseUnit !== undefined ? { baseUnit: values.baseUnit } : {}),
        ...(values.salePrice !== undefined
          ? { salePrice: values.salePrice }
          : {}),
        ...(values.purchasePrice !== undefined
          ? { purchasePrice: values.purchasePrice }
          : {}),
        ...(values.mrp !== undefined ? { mrp: values.mrp } : {}),
        ...(values.marketPrice !== undefined
          ? { marketPrice: values.marketPrice }
          : {}),
        ...(values.reorderLevel !== undefined
          ? { reorderLevel: values.reorderLevel }
          : {}),
        ...(values.primaryImageUrl !== undefined
          ? { primaryImageUrl: values.primaryImageUrl }
          : {}),
        ...(values.updatedBy !== undefined
          ? { updatedBy: values.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${items.syncVersion} + 1`,
      })
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .returning({
        id: items.id,
        name: items.name,
        description: items.description,
        itemType: items.itemType,
        hasStockTracking: items.hasStockTracking,
        categoryId: items.categoryId,
        categoryName: sql<string | null>`null`,
        brandId: items.brandId,
        brandName: sql<string | null>`null`,
        hsnCode: items.hsnCode,
        barcode: items.barcode,
        baseUnit: items.baseUnit,
        baseUnitId: sql<string | null>`null`,
        baseUnitName: sql<string | null>`null`,
        baseUnitSymbol: sql<string | null>`null`,
        salePrice: items.salePrice,
        purchasePrice: items.purchasePrice,
        mrp: items.mrp,
        marketPrice: items.marketPrice,
        reorderLevel: items.reorderLevel,
        primaryImageUrl: items.primaryImageUrl,
        createdAt: items.createdAt,
        updatedAt: items.updatedAt,
      });

    return row ? (row as ItemRow) : null;
  }

  async softDelete(
    businessId: string,
    itemId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(items)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${items.syncVersion} + 1`,
      })
      .where(
        and(
          eq(items.id, itemId),
          eq(items.businessId, businessId),
          eq(items.isDeleted, false),
        ),
      )
      .returning({ id: items.id });

    return Boolean(row);
  }

  async loadTierPrices(
    businessId: string,
    itemId: string,
  ): Promise<{ pricingTier: PricingTier; price: string }[]> {
    return this.db
      .select({
        pricingTier: itemTierPrices.pricingTier,
        price: itemTierPrices.price,
      })
      .from(itemTierPrices)
      .where(
        and(
          eq(itemTierPrices.businessId, businessId),
          eq(itemTierPrices.itemId, itemId),
          eq(itemTierPrices.isDeleted, false),
        ),
      )
      .orderBy(asc(itemTierPrices.pricingTier));
  }

  async loadImages(businessId: string, itemId: string) {
    return this.db
      .select({
        id: itemImages.id,
        imageUrl: itemImages.imageUrl,
        sortOrder: itemImages.sortOrder,
        isPrimary: itemImages.isPrimary,
        createdAt: itemImages.createdAt,
        updatedAt: itemImages.updatedAt,
      })
      .from(itemImages)
      .where(
        and(
          eq(itemImages.businessId, businessId),
          eq(itemImages.itemId, itemId),
          eq(itemImages.isDeleted, false),
        ),
      )
      .orderBy(asc(itemImages.sortOrder), asc(itemImages.createdAt));
  }

  async loadLocations(businessId: string, itemId: string) {
    return this.db
      .select({
        id: itemLocations.id,
        godownId: itemLocations.godownId,
        rack: itemLocations.rack,
        shelf: itemLocations.shelf,
      })
      .from(itemLocations)
      .where(
        and(
          eq(itemLocations.businessId, businessId),
          eq(itemLocations.itemId, itemId),
          eq(itemLocations.isDeleted, false),
        ),
      );
  }

  async hasNonOpeningMovements(
    businessId: string,
    itemId: string,
  ): Promise<boolean> {
    const [row] = await this.db
      .select({ total: count() })
      .from(inventoryMovements)
      .where(
        and(
          eq(inventoryMovements.businessId, businessId),
          eq(inventoryMovements.itemId, itemId),
          ne(inventoryMovements.movementType, 'opening'),
        ),
      );

    return Number(row?.total ?? 0) > 0;
  }

  async getTotalStockQuantity(
    businessId: string,
    itemId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({
        total: sql<string>`COALESCE(SUM(${stockLevels.quantity}::numeric), 0)`,
      })
      .from(stockLevels)
      .where(
        and(
          eq(stockLevels.businessId, businessId),
          eq(stockLevels.itemId, itemId),
          eq(stockLevels.isDeleted, false),
        ),
      );

    return parseMoney(row?.total ?? '0');
  }

  async loadOpeningStock(
    businessId: string,
    itemId: string,
  ): Promise<OpeningStockGodownSummary[]> {
    const rows = await this.db
      .select({
        godownId: stockLevels.godownId,
        godownName: godowns.name,
        quantity: stockLevels.quantity,
      })
      .from(stockLevels)
      .innerJoin(godowns, eq(stockLevels.godownId, godowns.id))
      .where(
        and(
          eq(stockLevels.businessId, businessId),
          eq(stockLevels.itemId, itemId),
          eq(stockLevels.isDeleted, false),
          eq(godowns.isDeleted, false),
        ),
      )
      .orderBy(asc(godowns.name));

    return rows.map((row) => ({
      godown_id: row.godownId,
      godown_name: row.godownName,
      quantity: row.quantity,
    }));
  }

  async listImages(
    businessId: string,
    itemId: string,
  ): Promise<ItemImageRecord[]> {
    const rows = await this.loadImages(businessId, itemId);
    return rows.map(toItemImageRecord);
  }

  async addImage(
    businessId: string,
    itemId: string,
    input: CreateItemImageInput,
  ): Promise<ItemImageRecord> {
    if (input.isPrimary) {
      await this.db
        .update(itemImages)
        .set({ isPrimary: false, updatedAt: new Date() })
        .where(
          and(
            eq(itemImages.businessId, businessId),
            eq(itemImages.itemId, itemId),
            eq(itemImages.isDeleted, false),
          ),
        );
    }

    const [row] = await this.db
      .insert(itemImages)
      .values({
        businessId,
        itemId,
        imageUrl: input.imageUrl,
        mediaAssetId: input.mediaAssetId ?? null,
        sortOrder: input.sortOrder ?? 0,
        isPrimary: input.isPrimary ?? false,
        createdBy: input.createdBy ?? null,
        updatedBy: input.updatedBy ?? null,
      })
      .returning({
        id: itemImages.id,
        imageUrl: itemImages.imageUrl,
        sortOrder: itemImages.sortOrder,
        isPrimary: itemImages.isPrimary,
        createdAt: itemImages.createdAt,
        updatedAt: itemImages.updatedAt,
      });

    if (!row) {
      throw new Error('Failed to add item image');
    }

    if (input.isPrimary) {
      await this.db
        .update(items)
        .set({
          primaryImageUrl: input.imageUrl,
          updatedAt: new Date(),
          syncVersion: sql`${items.syncVersion} + 1`,
        })
        .where(
          and(
            eq(items.id, itemId),
            eq(items.businessId, businessId),
            eq(items.isDeleted, false),
          ),
        );
    }

    return toItemImageRecord(row);
  }

  async findImageById(
    businessId: string,
    itemId: string,
    imageId: string,
  ): Promise<ItemImageRecord | null> {
    const [row] = await this.db
      .select({
        id: itemImages.id,
        imageUrl: itemImages.imageUrl,
        sortOrder: itemImages.sortOrder,
        isPrimary: itemImages.isPrimary,
        createdAt: itemImages.createdAt,
        updatedAt: itemImages.updatedAt,
      })
      .from(itemImages)
      .where(
        and(
          eq(itemImages.id, imageId),
          eq(itemImages.itemId, itemId),
          eq(itemImages.businessId, businessId),
          eq(itemImages.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? toItemImageRecord(row) : null;
  }

  async updateImage(
    businessId: string,
    itemId: string,
    imageId: string,
    input: UpdateItemImageInput,
  ): Promise<ItemImageRecord | null> {
    if (input.isPrimary) {
      await this.db
        .update(itemImages)
        .set({ isPrimary: false, updatedAt: new Date() })
        .where(
          and(
            eq(itemImages.businessId, businessId),
            eq(itemImages.itemId, itemId),
            eq(itemImages.isDeleted, false),
          ),
        );
    }

    const [row] = await this.db
      .update(itemImages)
      .set({
        ...(input.imageUrl !== undefined ? { imageUrl: input.imageUrl } : {}),
        ...(input.sortOrder !== undefined
          ? { sortOrder: input.sortOrder }
          : {}),
        ...(input.isPrimary !== undefined
          ? { isPrimary: input.isPrimary }
          : {}),
        ...(input.updatedBy !== undefined
          ? { updatedBy: input.updatedBy }
          : {}),
        updatedAt: new Date(),
        syncVersion: sql`${itemImages.syncVersion} + 1`,
      })
      .where(
        and(
          eq(itemImages.id, imageId),
          eq(itemImages.itemId, itemId),
          eq(itemImages.businessId, businessId),
          eq(itemImages.isDeleted, false),
        ),
      )
      .returning({
        id: itemImages.id,
        imageUrl: itemImages.imageUrl,
        sortOrder: itemImages.sortOrder,
        isPrimary: itemImages.isPrimary,
        createdAt: itemImages.createdAt,
        updatedAt: itemImages.updatedAt,
      });

    if (!row) return null;

    if (input.isPrimary && input.imageUrl) {
      await this.db
        .update(items)
        .set({
          primaryImageUrl: input.imageUrl,
          updatedAt: new Date(),
          syncVersion: sql`${items.syncVersion} + 1`,
        })
        .where(
          and(
            eq(items.id, itemId),
            eq(items.businessId, businessId),
            eq(items.isDeleted, false),
          ),
        );
    } else if (input.isPrimary) {
      await this.db
        .update(items)
        .set({
          primaryImageUrl: row.imageUrl,
          updatedAt: new Date(),
          syncVersion: sql`${items.syncVersion} + 1`,
        })
        .where(
          and(
            eq(items.id, itemId),
            eq(items.businessId, businessId),
            eq(items.isDeleted, false),
          ),
        );
    }

    return toItemImageRecord(row);
  }

  async softDeleteImage(
    businessId: string,
    itemId: string,
    imageId: string,
    updatedBy?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(itemImages)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: updatedBy ?? null,
        syncVersion: sql`${itemImages.syncVersion} + 1`,
      })
      .where(
        and(
          eq(itemImages.id, imageId),
          eq(itemImages.itemId, itemId),
          eq(itemImages.businessId, businessId),
          eq(itemImages.isDeleted, false),
        ),
      )
      .returning({
        id: itemImages.id,
        imageUrl: itemImages.imageUrl,
        isPrimary: itemImages.isPrimary,
      });

    if (!row) return false;

    if (row.isPrimary) {
      await this.db
        .update(items)
        .set({
          primaryImageUrl: null,
          updatedAt: new Date(),
          syncVersion: sql`${items.syncVersion} + 1`,
        })
        .where(
          and(
            eq(items.id, itemId),
            eq(items.businessId, businessId),
            eq(items.isDeleted, false),
          ),
        );
    }

    return true;
  }

  async exists(businessId: string, itemId: string): Promise<boolean> {
    const [row] = await this.db
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

    return row != null;
  }

  async countImages(businessId: string, itemId: string): Promise<number> {
    const [result] = await this.db
      .select({ total: count() })
      .from(itemImages)
      .where(
        and(
          eq(itemImages.businessId, businessId),
          eq(itemImages.itemId, itemId),
          eq(itemImages.isDeleted, false),
        ),
      );

    return Number(result?.total ?? 0);
  }

  async getImageMediaAssetId(
    businessId: string,
    itemId: string,
    imageId: string,
  ): Promise<string | null> {
    const [row] = await this.db
      .select({ mediaAssetId: itemImages.mediaAssetId })
      .from(itemImages)
      .where(
        and(
          eq(itemImages.id, imageId),
          eq(itemImages.itemId, itemId),
          eq(itemImages.businessId, businessId),
          eq(itemImages.isDeleted, false),
        ),
      )
      .limit(1);

    return row?.mediaAssetId ?? null;
  }

  async getImageMediaAssetIdByImageId(
    businessId: string,
    imageId: string,
  ): Promise<string | null> {
    const [row] = await this.db
      .select({ mediaAssetId: itemImages.mediaAssetId })
      .from(itemImages)
      .where(
        and(
          eq(itemImages.id, imageId),
          eq(itemImages.businessId, businessId),
          eq(itemImages.isDeleted, false),
        ),
      )
      .limit(1);

    return row?.mediaAssetId ?? null;
  }

  async getPrimaryImageMediaAssetId(
    businessId: string,
    itemId: string,
  ): Promise<string | null> {
    const [row] = await this.db
      .select({ mediaAssetId: itemImages.mediaAssetId })
      .from(itemImages)
      .where(
        and(
          eq(itemImages.businessId, businessId),
          eq(itemImages.itemId, itemId),
          eq(itemImages.isPrimary, true),
          eq(itemImages.isDeleted, false),
        ),
      )
      .limit(1);

    return row?.mediaAssetId ?? null;
  }

  async reorderImages(
    businessId: string,
    itemId: string,
    imageIds: string[],
  ): Promise<ItemImageRecord[]> {
    await this.db.transaction(async (tx) => {
      for (let index = 0; index < imageIds.length; index++) {
        const imageId = imageIds[index];
        if (!imageId) continue;

        await tx
          .update(itemImages)
          .set({
            sortOrder: index,
            updatedAt: new Date(),
            syncVersion: sql`${itemImages.syncVersion} + 1`,
          })
          .where(
            and(
              eq(itemImages.id, imageId),
              eq(itemImages.itemId, itemId),
              eq(itemImages.businessId, businessId),
              eq(itemImages.isDeleted, false),
            ),
          );
      }
    });

    return this.listImages(businessId, itemId);
  }

  async getTierPrices(
    businessId: string,
    itemId: string,
  ): Promise<ItemTierPriceRecord[]> {
    const rows = await this.loadTierPrices(businessId, itemId);
    return rows.map(toItemTierPriceRecord);
  }

  async replaceTierPrices(
    businessId: string,
    itemId: string,
    tierPrices: CreateItemTierPriceInput[],
    userId?: string | null,
  ): Promise<ItemTierPriceRecord[]> {
    return this.db.transaction(async (tx) => {
      const incomingTiers = tierPrices.map((tier) => tier.pricingTier);
      const now = new Date();

      const activeTierFilter = and(
        eq(itemTierPrices.businessId, businessId),
        eq(itemTierPrices.itemId, itemId),
        eq(itemTierPrices.isDeleted, false),
      );

      if (incomingTiers.length === 0) {
        await tx
          .update(itemTierPrices)
          .set({
            isDeleted: true,
            deletedAt: now,
            updatedAt: now,
            updatedBy: userId ?? null,
            syncVersion: sql`${itemTierPrices.syncVersion} + 1`,
          })
          .where(activeTierFilter);
      } else {
        await tx
          .update(itemTierPrices)
          .set({
            isDeleted: true,
            deletedAt: now,
            updatedAt: now,
            updatedBy: userId ?? null,
            syncVersion: sql`${itemTierPrices.syncVersion} + 1`,
          })
          .where(
            and(
              activeTierFilter,
              notInArray(itemTierPrices.pricingTier, incomingTiers),
            ),
          );
      }

      for (const tier of tierPrices) {
        const [existing] = await tx
          .select({ id: itemTierPrices.id })
          .from(itemTierPrices)
          .where(
            and(
              eq(itemTierPrices.businessId, businessId),
              eq(itemTierPrices.itemId, itemId),
              eq(itemTierPrices.pricingTier, tier.pricingTier),
            ),
          )
          .limit(1);

        if (existing) {
          await tx
            .update(itemTierPrices)
            .set({
              price: tier.price,
              isDeleted: false,
              deletedAt: null,
              updatedAt: now,
              updatedBy: userId ?? null,
              syncVersion: sql`${itemTierPrices.syncVersion} + 1`,
            })
            .where(eq(itemTierPrices.id, existing.id));
          continue;
        }

        await tx.insert(itemTierPrices).values({
          businessId,
          itemId,
          pricingTier: tier.pricingTier,
          price: tier.price,
          createdBy: userId ?? null,
          updatedBy: userId ?? null,
        });
      }

      const rows = await tx
        .select({
          pricingTier: itemTierPrices.pricingTier,
          price: itemTierPrices.price,
        })
        .from(itemTierPrices)
        .where(
          and(
            eq(itemTierPrices.businessId, businessId),
            eq(itemTierPrices.itemId, itemId),
            eq(itemTierPrices.isDeleted, false),
          ),
        )
        .orderBy(asc(itemTierPrices.pricingTier));

      return rows.map(toItemTierPriceRecord);
    });
  }

  async deleteTierPrice(
    businessId: string,
    itemId: string,
    pricingTier: PricingTier,
    userId?: string | null,
  ): Promise<boolean> {
    const [row] = await this.db
      .update(itemTierPrices)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
        updatedBy: userId ?? null,
        syncVersion: sql`${itemTierPrices.syncVersion} + 1`,
      })
      .where(
        and(
          eq(itemTierPrices.businessId, businessId),
          eq(itemTierPrices.itemId, itemId),
          eq(itemTierPrices.pricingTier, pricingTier),
          eq(itemTierPrices.isDeleted, false),
        ),
      )
      .returning({ id: itemTierPrices.id });

    return Boolean(row);
  }

  async listPriceHistory(
    businessId: string,
    itemId: string,
    page: number,
    limit: number,
  ): Promise<{ rows: ItemPriceHistoryRecord[]; total: number }> {
    const whereClause = and(
      eq(itemPriceHistory.businessId, businessId),
      eq(itemPriceHistory.itemId, itemId),
    );

    const countResult = await this.db
      .select({ total: count() })
      .from(itemPriceHistory)
      .where(whereClause);

    const total = Number(countResult[0]?.total ?? 0);
    const offset = (page - 1) * limit;

    const rows = await this.db
      .select({
        id: itemPriceHistory.id,
        price: itemPriceHistory.price,
        pricingTier: itemPriceHistory.pricingTier,
        changedBy: itemPriceHistory.changedBy,
        createdAt: itemPriceHistory.createdAt,
      })
      .from(itemPriceHistory)
      .where(whereClause)
      .orderBy(desc(itemPriceHistory.createdAt))
      .limit(limit)
      .offset(offset);

    return {
      rows: rows.map(toItemPriceHistoryRecord),
      total,
    };
  }

  runTransaction<T>(callback: (tx: DbTransaction) => Promise<T>): Promise<T> {
    return this.db.transaction(callback);
  }
}
