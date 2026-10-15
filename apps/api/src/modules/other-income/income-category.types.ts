export type IncomeCategoryRecord = {
  id: string;
  name: string;
  category_type: 'direct' | 'indirect';
  is_system: boolean;
  income_count: number;
  total_amount: string;
  created_at: string;
  updated_at: string;
};

export type IncomeCategoryInsertValues = {
  businessId: string;
  name: string;
  categoryType?: 'direct' | 'indirect';
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type IncomeCategoryUpdateValues = {
  name?: string;
  categoryType?: 'direct' | 'indirect';
  updatedBy?: string | null;
};

export type ListIncomeCategoriesParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  sort: 'name' | 'created_at';
  order: 'asc' | 'desc';
};

export type IncomeCategoryRow = {
  id: string;
  name: string;
  categoryType: 'direct' | 'indirect';
  isSystem: boolean;
  incomeCount: number;
  totalAmount: string;
  createdAt: Date;
  updatedAt: Date;
};
