export type GodownRecord = {
  id: string;
  name: string;
  address: string | null;
  is_default: boolean;
  stock_item_count: number;
  created_at: string;
  updated_at: string;
};

export type PaginatedGodownsResponse = {
  data: GodownRecord[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
};

export type GodownInsertValues = {
  businessId: string;
  name: string;
  address?: string | null;
  isDefault?: boolean;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type GodownUpdateValues = {
  name?: string;
  address?: string | null;
  isDefault?: boolean;
  updatedBy?: string | null;
};

export type ListGodownsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  sort: 'name' | 'created_at';
  order: 'asc' | 'desc';
};

export type GodownRow = {
  id: string;
  name: string;
  address: string | null;
  isDefault: boolean;
  stockItemCount: number;
  createdAt: Date;
  updatedAt: Date;
};
