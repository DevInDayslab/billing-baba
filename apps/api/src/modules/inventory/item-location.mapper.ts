import type {
  ItemLocationRecord,
  ItemLocationRow,
} from './item-location.types';

export function toItemLocationRecord(row: ItemLocationRow): ItemLocationRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    godown_id: row.godownId,
    rack: row.rack,
    shelf: row.shelf,
    photo_url: row.photoUrl,
    photo_taken_at: row.photoTakenAt?.toISOString() ?? null,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
