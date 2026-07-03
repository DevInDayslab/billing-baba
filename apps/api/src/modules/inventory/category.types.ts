export type CategoryRecord = {
  id: string;
  name: string;
  item_count: number;
  created_at: string;
  updated_at: string;
};

export type PaginatedCategoriesResponse = {
  success: true;
  data: CategoryRecord[];
  meta: {
    page: number;
    limit: number;
    total: number;
  };
};

export type CategoryInsertValues = {
  businessId: string;
  name: string;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type CategoryUpdateValues = {
  name?: string;
  updatedBy?: string | null;
};

export type ListCategoriesParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  sort: 'name' | 'created_at';
  order: 'asc' | 'desc';
};

export type CategoryRow = {
  id: string;
  name: string;
  itemCount: number;
  createdAt: Date;
  updatedAt: Date;
};
