export type ExpenseItemRecord = {
  id: string;
  name: string;
  hsn_sac: string | null;
  price: string;
  price_is_tax_inclusive: boolean;
  tax_rate: string;
  expense_count: number;
  total_amount: string;
  created_at: string;
  updated_at: string;
};

export type ExpenseItemInsertValues = {
  businessId: string;
  name: string;
  hsnSac?: string | null;
  price?: string;
  priceIsTaxInclusive?: boolean;
  taxRate?: string;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type ExpenseItemUpdateValues = {
  name?: string;
  hsnSac?: string | null;
  price?: string;
  priceIsTaxInclusive?: boolean;
  taxRate?: string;
  updatedBy?: string | null;
};

export type ListExpenseItemsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  sort: 'name' | 'created_at' | 'price';
  order: 'asc' | 'desc';
};

export type ExpenseItemRow = {
  id: string;
  name: string;
  hsnSac: string | null;
  price: string;
  priceIsTaxInclusive: boolean;
  taxRate: string;
  expenseCount: number;
  totalAmount: string;
  createdAt: Date;
  updatedAt: Date;
};
