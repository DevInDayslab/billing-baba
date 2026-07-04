export type ItemLocationRecord = {
  id: string;
  item_id: string;
  godown_id: string;
  rack: string | null;
  shelf: string | null;
  photo_url: string | null;
  photo_taken_at: string | null;
  created_at: string;
  updated_at: string;
};

export type PaginatedItemLocationsResponse = {
  success: true;
  data: ItemLocationRecord[];
  meta: { page: number; limit: number; total: number };
};

export type ItemLocationInsertValues = {
  businessId: string;
  itemId: string;
  godownId: string;
  rack?: string | null;
  shelf?: string | null;
  photoUrl?: string | null;
  photoTakenAt?: Date | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type ItemLocationUpdateValues = {
  godownId?: string;
  rack?: string | null;
  shelf?: string | null;
  photoUrl?: string | null;
  photoTakenAt?: Date | null;
  updatedBy?: string | null;
};

export type ListItemLocationsParams = {
  businessId: string;
  page: number;
  limit: number;
  itemId?: string;
  godownId?: string;
  sort: 'created_at';
  order: 'asc' | 'desc';
};

export type ItemLocationRow = {
  id: string;
  itemId: string;
  godownId: string;
  rack: string | null;
  shelf: string | null;
  photoUrl: string | null;
  photoTakenAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
};
