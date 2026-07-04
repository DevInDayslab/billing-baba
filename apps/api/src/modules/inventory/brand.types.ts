export type BrandRecord = {
  id: string;
  name: string;
  item_count: number;
  created_at: string;
  updated_at: string;
};

export type PaginatedBrandsResponse = {
  success: true;
  data: BrandRecord[];
  meta: {
    page: number;
    limit: number;
    total: number;
  };
};

export type BrandInsertValues = {
  businessId: string;
  name: string;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type BrandUpdateValues = {
  name?: string;
  updatedBy?: string | null;
};

export type ListBrandsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  sort: 'name' | 'created_at';
  order: 'asc' | 'desc';
};

export type BrandRow = {
  id: string;
  name: string;
  itemCount: number;
  createdAt: Date;
  updatedAt: Date;
};
