import type {
  PriceHistoryRecord,
  PriceHistoryRow,
} from './price-history.types';

export function toPriceHistoryRecord(row: PriceHistoryRow): PriceHistoryRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    item_name: row.itemName,
    price: row.price,
    pricing_tier: row.pricingTier,
    changed_by: row.changedBy,
    created_at: row.createdAt.toISOString(),
  };
}
