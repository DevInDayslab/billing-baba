import type {
  ItemLocationHistoryRecord,
  ItemLocationHistoryRow,
} from './item-location-history.types';

export function toItemLocationHistoryRecord(
  row: ItemLocationHistoryRow,
): ItemLocationHistoryRecord {
  return {
    id: row.id,
    item_location_id: row.itemLocationId,
    item_id: row.itemId,
    rack: row.rack,
    shelf: row.shelf,
    photo_url: row.photoUrl,
    photo_media_asset_id: row.photoMediaAssetId,
    employee_label: row.employeeLabel,
    changed_by: row.changedBy,
    created_at: row.createdAt.toISOString(),
  };
}
