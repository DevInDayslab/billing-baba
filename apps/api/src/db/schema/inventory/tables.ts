import { sql } from 'drizzle-orm';
import {
  boolean,
  integer,
  jsonb,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import {
  money,
  syncedBusinessColumns,
  timestamptz,
  uuidPrimaryKey,
} from '../columns';
import {
  inventoryMovementTypeEnum,
  itemTypeEnum,
  pricingTierEnum,
} from '../enums';
import { users } from '../identity/tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export { itemAlternatives } from './item-alternatives.table';

export const categories = pgTable('categories', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  name: text('name').notNull(),
});

export const unitDefinitions = pgTable(
  'unit_definitions',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    shortName: text('short_name').notNull(),
    symbol: text('symbol'),
    decimalPlaces: integer('decimal_places').notNull().default(0),
    isSystem: boolean('is_system').notNull().default(false),
    isActive: boolean('is_active').notNull().default(true),
  },
  (table) => [
    uniqueIndex('uq_unit_definitions_business_name_active')
      .on(table.businessId, sql`lower(${table.name})`)
      .where(sql`${table.isDeleted} = false`),
    uniqueIndex('uq_unit_definitions_business_short_name_active')
      .on(table.businessId, sql`lower(${table.shortName})`)
      .where(sql`${table.isDeleted} = false`),
  ],
);

export const unitConversions = pgTable(
  'unit_conversions',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    fromUnitId: uuid('from_unit_id')
      .notNull()
      .references(() => unitDefinitions.id),
    toUnitId: uuid('to_unit_id')
      .notNull()
      .references(() => unitDefinitions.id),
    conversionFactor: money('conversion_factor').notNull(),
  },
  (table) => [
    uniqueIndex('uq_unit_conversions_business_pair_active')
      .on(table.businessId, table.fromUnitId, table.toUnitId)
      .where(sql`${table.isDeleted} = false`),
  ],
);

export const brands = pgTable('brands', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  name: text('name').notNull(),
});

export const items = pgTable(
  'items',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    shortName: text('short_name'),
    alias: text('alias'),
    searchKeywords: text('search_keywords'),
    description: text('description'),
    itemType: itemTypeEnum('item_type').notNull().default('product'),
    hasStockTracking: boolean('has_stock_tracking').notNull().default(true),
    categoryId: uuid('category_id').references(() => categories.id),
    brandId: uuid('brand_id').references(() => brands.id),
    hsnCode: text('hsn_code'),
    barcode: text('barcode'),
    baseUnit: text('base_unit').notNull().default('piece'),
    mrp: money('mrp'),
    isMrpOnly: boolean('is_mrp_only').notNull().default(false),
    marketPrice: money('market_price'),
    salePrice: money('sale_price').notNull().default('0'),
    purchasePrice: money('purchase_price').notNull().default('0'),
    reorderLevel: money('reorder_level'),
    defaultTaxRate: money('default_tax_rate'),
    primaryImageUrl: text('primary_image_url'),
  },
  (table) => [
    uniqueIndex('uq_items_business_barcode_active')
      .on(table.businessId, table.barcode)
      .where(sql`${table.isDeleted} = false AND ${table.barcode} IS NOT NULL`),
  ],
);

export const itemImages = pgTable('item_images', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  itemId: uuid('item_id')
    .notNull()
    .references(() => items.id),
  imageUrl: text('image_url').notNull(),
  mediaAssetId: uuid('media_asset_id'),
  sortOrder: integer('sort_order').notNull().default(0),
  isPrimary: boolean('is_primary').notNull().default(false),
});

export const itemUnits = pgTable(
  'item_units',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    itemId: uuid('item_id')
      .notNull()
      .references(() => items.id),
    unitName: text('unit_name').notNull(),
    conversionFactor: money('conversion_factor').notNull(),
  },
  (table) => [
    uniqueIndex('uq_item_units_item_unit').on(table.itemId, table.unitName),
  ],
);

export const itemTierPrices = pgTable(
  'item_tier_prices',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    itemId: uuid('item_id')
      .notNull()
      .references(() => items.id),
    pricingTier: pricingTierEnum('pricing_tier').notNull(),
    price: money('price').notNull(),
  },
  (table) => [
    uniqueIndex('uq_item_tier_prices_item_tier').on(
      table.itemId,
      table.pricingTier,
    ),
  ],
);

/** Immutable — append-only price audit */
export const itemPriceHistory = pgTable('item_price_history', {
  id: uuidPrimaryKey(),
  businessId: uuid('business_id')
    .notNull()
    .references(() => businesses.id),
  itemId: uuid('item_id')
    .notNull()
    .references(() => items.id),
  price: money('price').notNull(),
  pricingTier: pricingTierEnum('pricing_tier'),
  changedBy: uuid('changed_by').references(() => users.id),
  createdAt: timestamptz('created_at').notNull().defaultNow(),
});

export const godowns = pgTable('godowns', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  name: text('name').notNull(),
  address: text('address'),
  isDefault: boolean('is_default').notNull().default(false),
});

export const itemLocations = pgTable('item_locations', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  itemId: uuid('item_id')
    .notNull()
    .references(() => items.id),
  godownId: uuid('godown_id')
    .notNull()
    .references(() => godowns.id),
  rack: text('rack'),
  shelf: text('shelf'),
  photoUrl: text('photo_url'),
  photoMediaAssetId: uuid('photo_media_asset_id'),
  photoTakenAt: timestamptz('photo_taken_at'),
});

export const stockLevels = pgTable(
  'stock_levels',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    itemId: uuid('item_id')
      .notNull()
      .references(() => items.id),
    godownId: uuid('godown_id')
      .notNull()
      .references(() => godowns.id),
    quantity: money('quantity').notNull().default('0'),
    averageCost: money('average_cost').notNull().default('0'),
    reorderLevel: money('reorder_level'),
  },
  (table) => [
    uniqueIndex('uq_stock_levels_business_item_godown').on(
      table.businessId,
      table.itemId,
      table.godownId,
    ),
  ],
);

/** Immutable event ledger — source of truth for stock */
export const inventoryMovements = pgTable('inventory_movements', {
  id: uuidPrimaryKey(),
  businessId: uuid('business_id')
    .notNull()
    .references(() => businesses.id),
  itemId: uuid('item_id')
    .notNull()
    .references(() => items.id),
  godownId: uuid('godown_id')
    .notNull()
    .references(() => godowns.id),
  movementType: inventoryMovementTypeEnum('movement_type').notNull(),
  quantityDelta: money('quantity_delta').notNull(),
  costPerUnit: money('cost_per_unit'),
  unit: text('unit'),
  referenceId: uuid('reference_id'),
  referenceType: text('reference_type'),
  notes: text('notes'),
  createdAt: timestamptz('created_at').notNull().defaultNow(),
  createdBy: uuid('created_by').references(() => users.id),
});
