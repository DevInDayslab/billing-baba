export type ExpenseCategoryRecord = {
  id: string;
  name: string;
  category_type: 'direct' | 'indirect';
  is_system: boolean;
  expense_count: number;
  total_amount: string;
  created_at: string;
  updated_at: string;
};

export type ExpenseCategoryInsertValues = {
  businessId: string;
  name: string;
  categoryType?: 'direct' | 'indirect';
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type ExpenseCategoryUpdateValues = {
  name?: string;
  categoryType?: 'direct' | 'indirect';
  updatedBy?: string | null;
};

export type ListExpenseCategoriesParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  sort: 'name' | 'created_at';
  order: 'asc' | 'desc';
};

export type ExpenseCategoryRow = {
  id: string;
  name: string;
  categoryType: 'direct' | 'indirect';
  isSystem: boolean;
  expenseCount: number;
  totalAmount: string;
  createdAt: Date;
  updatedAt: Date;
};
