export type ItemLocationHistoryRecord = {
  id: string;
  item_location_id: string;
  item_id: string;
  rack: string | null;
  shelf: string | null;
  photo_url: string | null;
  photo_media_asset_id: string | null;
  employee_label: string | null;
  changed_by: string | null;
  created_at: string;
};

export type ItemLocationHistoryRow = {
  id: string;
  itemLocationId: string;
  itemId: string;
  rack: string | null;
  shelf: string | null;
  photoUrl: string | null;
  photoMediaAssetId: string | null;
  employeeLabel: string | null;
  changedBy: string | null;
  createdAt: Date;
};

export type InsertItemLocationHistoryInput = {
  businessId: string;
  itemLocationId: string;
  itemId: string;
  rack?: string | null;
  shelf?: string | null;
  photoUrl?: string | null;
  photoMediaAssetId?: string | null;
  employeeLabel?: string | null;
  changedBy?: string | null;
};

export type ListItemLocationHistoryParams = {
  businessId: string;
  itemLocationId: string;
  page: number;
  limit: number;
};
