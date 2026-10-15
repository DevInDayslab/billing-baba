export type OtherIncomeRecord = {
  id: string;
  category_id: string;
  category_name: string;
  income_item_id: string | null;
  income_item_name: string | null;
  amount: string;
  quantity: string | null;
  tax_amount: string;
  tax_rate: string;
  description: string | null;
  notes: string | null;
  reference_number: string | null;
  income_date: string;
  payment_mode: string | null;
  bank_account_id: string | null;
  due_date: string | null;
  balance_due: string | null;
  created_at: string;
  updated_at: string;
};

export type OtherIncomeInsertValues = {
  businessId: string;
  categoryId: string;
  incomeItemId?: string | null;
  amount: string;
  quantity?: string | null;
  taxAmount?: string;
  taxRate?: string;
  description?: string | null;
  notes?: string | null;
  referenceNumber?: string | null;
  incomeDate: string;
  paymentMode?: string | null;
  bankAccountId?: string | null;
  dueDate?: string | null;
  balanceDue?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type OtherIncomeUpdateValues = {
  categoryId?: string;
  incomeItemId?: string | null;
  amount?: string;
  quantity?: string | null;
  taxAmount?: string;
  taxRate?: string;
  description?: string | null;
  notes?: string | null;
  referenceNumber?: string | null;
  incomeDate?: string;
  paymentMode?: string | null;
  bankAccountId?: string | null;
  dueDate?: string | null;
  balanceDue?: string | null;
  updatedBy?: string | null;
};

export type ListOtherIncomesParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  categoryId?: string;
  incomeItemId?: string;
  from?: string;
  to?: string;
  minAmount?: string;
  maxAmount?: string;
  paymentMode?: string;
  sort: 'income_date' | 'created_at' | 'amount';
  order: 'asc' | 'desc';
};

export type OtherIncomeRow = {
  id: string;
  categoryId: string;
  categoryName: string;
  incomeItemId: string | null;
  incomeItemName: string | null;
  amount: string;
  quantity: string | null;
  taxAmount: string;
  taxRate: string;
  description: string | null;
  notes: string | null;
  referenceNumber: string | null;
  incomeDate: string;
  paymentMode: string | null;
  bankAccountId: string | null;
  dueDate: string | null;
  balanceDue: string | null;
  createdAt: Date;
  updatedAt: Date;
};
