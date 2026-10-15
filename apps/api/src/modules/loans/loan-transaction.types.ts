export type LoanTransactionType = 'increase' | 'repayment' | 'charges';

export type LoanTransactionRecord = {
  id: string;
  loan_account_id: string;
  loan_account_name: string;
  transaction_type: LoanTransactionType;
  transaction_date: string;
  principal_amount: string;
  interest_amount: string;
  charges_amount: string;
  bank_account_id: string;
  description: string | null;
  reference_number: string | null;
  created_at: string;
  updated_at: string;
};

export type LoanTransactionInsertValues = {
  businessId: string;
  loanAccountId: string;
  transactionType: LoanTransactionType;
  transactionDate: string;
  principalAmount?: string;
  interestAmount?: string;
  chargesAmount?: string;
  bankAccountId: string;
  description?: string | null;
  referenceNumber?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type LoanTransactionUpdateValues = {
  loanAccountId?: string;
  transactionType?: LoanTransactionType;
  transactionDate?: string;
  principalAmount?: string;
  interestAmount?: string;
  chargesAmount?: string;
  bankAccountId?: string;
  description?: string | null;
  referenceNumber?: string | null;
  updatedBy?: string | null;
};

export type ListLoanTransactionsParams = {
  businessId: string;
  page: number;
  limit: number;
  loanAccountId?: string;
  transactionType?: LoanTransactionType;
  from?: string;
  to?: string;
  q?: string;
  sort: 'transaction_date' | 'created_at';
  order: 'asc' | 'desc';
};

export type LoanTransactionRow = {
  id: string;
  loanAccountId: string;
  loanAccountName: string;
  transactionType: LoanTransactionType;
  transactionDate: string;
  principalAmount: string;
  interestAmount: string;
  chargesAmount: string;
  bankAccountId: string;
  description: string | null;
  referenceNumber: string | null;
  createdAt: Date;
  updatedAt: Date;
};
