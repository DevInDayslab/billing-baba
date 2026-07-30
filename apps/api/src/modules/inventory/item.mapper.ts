import { pricingTierLabel } from '../../shared/pricing/pricing-tier';
import { parseSearchKeywords } from './inventory.utils';
import type {
  BaseUnitSummary,
  BrandSummary,
  CategorySummary,
  ItemDetailRecord,
  ItemImageRecord,
  ItemImageRow,
  ItemListRecord,
  ItemLocationRow,
  ItemLocationSummary,
  ItemPriceHistoryRecord,
  ItemPriceHistoryRow,
  ItemRow,
  ItemTierPriceRecord,
  ItemTierPriceRow,
  OpeningStockGodownSummary,
  OpeningStockSummary,
} from './item.types';

function toCategorySummary(
  categoryId: string | null,
  categoryName: string | null,
): CategorySummary {
  if (!categoryId || !categoryName) return null;
  return { id: categoryId, name: categoryName };
}

function toBrandSummary(
  brandId: string | null,
  brandName: string | null,
): BrandSummary {
  if (!brandId || !brandName) return null;
  return { id: brandId, name: brandName };
}

function toBaseUnitSummary(row: ItemRow): BaseUnitSummary {
  if (!row.baseUnitId || !row.baseUnitName) return null;
  return {
    id: row.baseUnitId,
    name: row.baseUnitName,
    short_name: row.baseUnit,
    symbol: row.baseUnitSymbol,
  };
}

export function toItemListRecord(
  row: ItemRow,
  alternativeItemIds: string[] = [],
): ItemListRecord {
  return {
    id: row.id,
    name: row.name,
    short_name: row.shortName,
    alias: row.alias,
    search_keywords: parseSearchKeywords(row.searchKeywords),
    description: row.description,
    item_type: row.itemType,
    has_stock_tracking: row.hasStockTracking,
    category_id: row.categoryId,
    category: toCategorySummary(row.categoryId, row.categoryName),
    brand_id: row.brandId,
    brand: toBrandSummary(row.brandId, row.brandName),
    hsn_code: row.hsnCode,
    barcode: row.barcode,
    base_unit: row.baseUnit,
    base_unit_detail: toBaseUnitSummary(row),
    sale_price: row.salePrice,
    purchase_price: row.purchasePrice,
    mrp: row.mrp,
    market_price: row.marketPrice,
    reorder_level: row.reorderLevel,
    default_tax_rate: row.defaultTaxRate,
    primary_image_url: row.primaryImageUrl,
    alternative_item_ids: alternativeItemIds,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

export function toItemTierPriceRecord(
  row: ItemTierPriceRow,
): ItemTierPriceRecord {
  return {
    pricing_tier: row.pricingTier,
    tier_label: pricingTierLabel(row.pricingTier),
    price: row.price,
  };
}

export function toItemImageRecord(row: ItemImageRow): ItemImageRecord {
  return {
    id: row.id,
    image_url: row.imageUrl,
    sort_order: row.sortOrder,
    is_primary: row.isPrimary,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}

export function toItemLocationSummary(
  row: ItemLocationRow,
): ItemLocationSummary {
  return {
    id: row.id,
    godown_id: row.godownId,
    rack: row.rack,
    shelf: row.shelf,
  };
}

export function toItemPriceHistoryRecord(
  row: ItemPriceHistoryRow,
): ItemPriceHistoryRecord {
  return {
    id: row.id,
    price: row.price,
    pricing_tier: row.pricingTier,
    changed_by: row.changedBy,
    created_at: row.createdAt.toISOString(),
  };
}

export function toOpeningStockSummary(
  rows: OpeningStockGodownSummary[],
): OpeningStockSummary {
  const total = rows.reduce((sum, row) => sum + Number(row.quantity), 0);
  return {
    total_quantity: String(total),
    godowns: rows,
  };
}

export function toItemDetailRecord(
  row: ItemRow,
  tierPrices: ItemTierPriceRow[],
  images: ItemImageRow[],
  locations: ItemLocationRow[],
  openingStock: OpeningStockGodownSummary[],
  alternativeItemIds: string[] = [],
): ItemDetailRecord {
  return {
    ...toItemListRecord(row, alternativeItemIds),
    tier_prices: tierPrices.map(toItemTierPriceRecord),
    images: images.map(toItemImageRecord),
    locations: locations.map(toItemLocationSummary),
    opening_stock: toOpeningStockSummary(openingStock),
  };
}
