export type LoanAccountRecord = {
  id: string;
  name: string;
  lender_name: string | null;
  account_number: string | null;
  description: string | null;
  opening_outstanding: string;
  opening_balance_as_of: string;
  interest_rate: string | null;
  term_months: number | null;
  received_bank_account_id: string | null;
  created_at: string;
  updated_at: string;
};

export type LoanAccountInsertValues = {
  businessId: string;
  name: string;
  lenderName?: string | null;
  accountNumber?: string | null;
  description?: string | null;
  openingOutstanding?: string;
  openingBalanceAsOf: string;
  interestRate?: string | null;
  termMonths?: number | null;
  receivedBankAccountId?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type LoanAccountUpdateValues = {
  name?: string;
  lenderName?: string | null;
  accountNumber?: string | null;
  description?: string | null;
  openingOutstanding?: string;
  openingBalanceAsOf?: string;
  interestRate?: string | null;
  termMonths?: number | null;
  receivedBankAccountId?: string | null;
  updatedBy?: string | null;
};

export type ListLoanAccountsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  sort: 'name' | 'created_at' | 'opening_balance_as_of';
  order: 'asc' | 'desc';
};

export type LoanAccountRow = {
  id: string;
  name: string;
  lenderName: string | null;
  accountNumber: string | null;
  description: string | null;
  openingOutstanding: string;
  openingBalanceAsOf: string;
  interestRate: string | null;
  termMonths: number | null;
  receivedBankAccountId: string | null;
  createdAt: Date;
  updatedAt: Date;
};
