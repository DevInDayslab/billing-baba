import type { BrandRecord, BrandRow } from './brand.types';

export function toBrandRecord(row: BrandRow): BrandRecord {
  return {
    id: row.id,
    name: row.name,
    item_count: row.itemCount,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
