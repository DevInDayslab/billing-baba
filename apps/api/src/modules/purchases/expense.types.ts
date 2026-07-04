export type ExpenseRecord = {
  id: string;
  category_id: string;
  category_name: string;
  party_id: string | null;
  party_name: string | null;
  amount: string;
  tax_amount: string;
  tax_rate: string;
  description: string | null;
  notes: string | null;
  reference_number: string | null;
  attachments: string[];
  expense_date: string;
  payment_mode: string | null;
  created_at: string;
  updated_at: string;
};

export type ExpenseInsertValues = {
  businessId: string;
  categoryId: string;
  partyId?: string | null;
  amount: string;
  taxAmount?: string;
  taxRate?: string;
  description?: string | null;
  notes?: string | null;
  referenceNumber?: string | null;
  attachments?: string[];
  expenseDate: string;
  paymentMode?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type ExpenseUpdateValues = {
  categoryId?: string;
  partyId?: string | null;
  amount?: string;
  taxAmount?: string;
  taxRate?: string;
  description?: string | null;
  notes?: string | null;
  referenceNumber?: string | null;
  attachments?: string[];
  expenseDate?: string;
  paymentMode?: string | null;
  updatedBy?: string | null;
};

export type ListExpensesParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  categoryId?: string;
  partyId?: string;
  from?: string;
  to?: string;
  minAmount?: string;
  maxAmount?: string;
  paymentMode?: string;
  sort: 'expense_date' | 'created_at' | 'amount';
  order: 'asc' | 'desc';
};

export type ExpenseRow = {
  id: string;
  categoryId: string;
  categoryName: string;
  partyId: string | null;
  partyName: string | null;
  amount: string;
  taxAmount: string;
  taxRate: string;
  description: string | null;
  notes: string | null;
  referenceNumber: string | null;
  attachments: string[] | null;
  expenseDate: string;
  paymentMode: string | null;
  createdAt: Date;
  updatedAt: Date;
};
