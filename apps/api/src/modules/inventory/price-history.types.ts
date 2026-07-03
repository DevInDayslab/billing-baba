import type { PricingTier } from './item.types';

export type PriceHistoryRecord = {
  id: string;
  item_id: string;
  item_name: string;
  price: string;
  pricing_tier: PricingTier | null;
  changed_by: string | null;
  created_at: string;
};

export type PaginatedPriceHistoryResponse = {
  success: true;
  data: PriceHistoryRecord[];
  meta: { page: number; limit: number; total: number };
};

export type PriceHistoryRow = {
  id: string;
  itemId: string;
  itemName: string;
  price: string;
  pricingTier: PricingTier | null;
  changedBy: string | null;
  createdAt: Date;
};

export type ListPriceHistoryParams = {
  businessId: string;
  page: number;
  limit: number;
  itemId?: string;
};
