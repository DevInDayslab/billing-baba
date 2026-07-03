import type { GodownRecord, GodownRow } from './godown.types';

export function toGodownRecord(row: GodownRow): GodownRecord {
  return {
    id: row.id,
    name: row.name,
    address: row.address,
    is_default: row.isDefault,
    stock_item_count: row.stockItemCount,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
