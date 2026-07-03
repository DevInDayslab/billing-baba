import type { CategoryRecord, CategoryRow } from './category.types';

export function toCategoryRecord(row: CategoryRow): CategoryRecord {
  return {
    id: row.id,
    name: row.name,
    item_count: row.itemCount,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
