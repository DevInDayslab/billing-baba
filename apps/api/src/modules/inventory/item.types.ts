import type {
  PricingTier,
  PricingTierLabel,
} from '../../shared/pricing/pricing-tier';

export type ItemType = 'product' | 'service';
export type { PricingTier, PricingTierLabel };

export type ItemTierPriceRecord = {
  pricing_tier: PricingTier;
  tier_label: PricingTierLabel;
  price: string;
};

export type ItemImageRecord = {
  id: string;
  image_url: string;
  thumbnail_url?: string | null;
  medium_url?: string | null;
  sort_order: number;
  is_primary: boolean;
  created_at: string;
  updated_at: string;
};

export type ItemPriceHistoryRecord = {
  id: string;
  price: string;
  pricing_tier: PricingTier | null;
  changed_by: string | null;
  created_at: string;
};

export type ItemLocationSummary = {
  id: string;
  godown_id: string;
  rack: string | null;
  shelf: string | null;
};

export type CategorySummary = { id: string; name: string } | null;
export type BrandSummary = { id: string; name: string } | null;
export type BaseUnitSummary = {
  id: string;
  name: string;
  short_name: string;
  symbol: string | null;
} | null;

export type OpeningStockGodownSummary = {
  godown_id: string;
  godown_name: string;
  quantity: string;
};

export type OpeningStockSummary = {
  total_quantity: string;
  godowns: OpeningStockGodownSummary[];
};

export type ItemListRecord = {
  id: string;
  name: string;
  short_name: string | null;
  alias: string | null;
  search_keywords: string[];
  description: string | null;
  item_type: ItemType;
  has_stock_tracking: boolean;
  category_id: string | null;
  category: CategorySummary;
  brand_id: string | null;
  brand: BrandSummary;
  hsn_code: string | null;
  barcode: string | null;
  base_unit: string;
  base_unit_detail: BaseUnitSummary;
  sale_price: string;
  purchase_price: string;
  mrp: string | null;
  market_price: string | null;
  reorder_level: string | null;
  default_tax_rate: string | null;
  primary_image_url: string | null;
  alternative_item_ids: string[];
  quantity?: string;
  reserved_quantity?: string;
  available_for_sale?: string;
  created_at: string;
  updated_at: string;
};

export type ItemDetailRecord = ItemListRecord & {
  tier_prices: ItemTierPriceRecord[];
  images: ItemImageRecord[];
  locations: ItemLocationSummary[];
  opening_stock: OpeningStockSummary;
};

export type PaginatedItemsResponse = {
  success: true;
  data: ItemListRecord[];
  meta: { page: number; limit: number; total: number };
};

export type ItemInsertValues = {
  businessId: string;
  name: string;
  shortName?: string | null;
  alias?: string | null;
  searchKeywords?: string | null;
  description?: string | null;
  itemType: ItemType;
  hasStockTracking: boolean;
  categoryId?: string | null;
  brandId?: string | null;
  hsnCode?: string | null;
  barcode?: string | null;
  baseUnit: string;
  salePrice: string;
  purchasePrice: string;
  mrp?: string | null;
  marketPrice?: string | null;
  reorderLevel?: string | null;
  defaultTaxRate?: string | null;
  primaryImageUrl?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type ItemUpdateValues = {
  name?: string;
  shortName?: string | null;
  alias?: string | null;
  searchKeywords?: string | null;
  description?: string | null;
  itemType?: ItemType;
  hasStockTracking?: boolean;
  categoryId?: string | null;
  brandId?: string | null;
  hsnCode?: string | null;
  barcode?: string | null;
  baseUnit?: string;
  salePrice?: string;
  purchasePrice?: string;
  mrp?: string | null;
  marketPrice?: string | null;
  reorderLevel?: string | null;
  defaultTaxRate?: string | null;
  primaryImageUrl?: string | null;
  updatedBy?: string | null;
};

export type ListItemsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  type?: ItemType;
  categoryId?: string;
  brandId?: string;
  hsn?: string;
  barcode?: string;
  sort: 'name' | 'created_at';
  order: 'asc' | 'desc';
};

export type ItemRow = {
  id: string;
  name: string;
  shortName: string | null;
  alias: string | null;
  searchKeywords: string | null;
  description: string | null;
  itemType: ItemType;
  hasStockTracking: boolean;
  categoryId: string | null;
  categoryName: string | null;
  brandId: string | null;
  brandName: string | null;
  hsnCode: string | null;
  barcode: string | null;
  baseUnit: string;
  baseUnitId: string | null;
  baseUnitName: string | null;
  baseUnitSymbol: string | null;
  salePrice: string;
  purchasePrice: string;
  mrp: string | null;
  marketPrice: string | null;
  reorderLevel: string | null;
  defaultTaxRate: string | null;
  primaryImageUrl: string | null;
  createdAt: Date;
  updatedAt: Date;
};

export type ItemTierPriceRow = {
  pricingTier: PricingTier;
  price: string;
};

export type ItemImageRow = {
  id: string;
  imageUrl: string;
  sortOrder: number;
  isPrimary: boolean;
  createdAt: Date;
  updatedAt: Date;
};

export type ItemLocationRow = {
  id: string;
  godownId: string;
  rack: string | null;
  shelf: string | null;
};

export type ItemPriceHistoryRow = {
  id: string;
  price: string;
  pricingTier: PricingTier | null;
  changedBy: string | null;
  createdAt: Date;
};

export type CreateItemLocationInput = {
  godownId: string;
  rack?: string | null;
  shelf?: string | null;
};

export type CreateItemTierPriceInput = {
  pricingTier: PricingTier;
  price: string;
};

export type CreateItemImageInput = {
  imageUrl: string;
  mediaAssetId?: string | null;
  sortOrder?: number;
  isPrimary?: boolean;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type UpdateItemImageInput = {
  imageUrl?: string;
  sortOrder?: number;
  isPrimary?: boolean;
  updatedBy?: string | null;
};

export type RecordPriceHistoryInput = {
  price: string;
  pricingTier?: PricingTier | null;
  changedBy?: string | null;
};
