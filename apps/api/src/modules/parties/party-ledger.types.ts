export type PartyLedgerSummaryRecord = {
  opening_balance: string;
  outstanding: string;
  receive_amount: string;
  payable_amount: string;
  credit_limit: string | null;
  status: 'active' | 'inactive';
  last_transaction_date: string | null;
  total_sales: string;
  total_purchases: string;
  total_payments: string;
};

export type PartyLedgerTransactionRecord = {
  id: string;
  date: string;
  created_at: string;
  type: string;
  entry_type: string;
  source: string;
  source_type: string;
  reference_id: string | null;
  reference_type: string | null;
  reference_number: string | null;
  description: string | null;
  document_date: string;
  total: string;
  balance: string;
  due_date: string | null;
  status: string | null;
  debit: string;
  credit: string;
  balance_after: string;
  direction?: 'received' | 'paid';
  payment_status?: 'Paid' | 'Partial' | 'Unpaid' | null;
};

export type PartyLedgerPayload = {
  party_id: string;
  summary: PartyLedgerSummaryRecord;
  transactions: PartyLedgerTransactionRecord[];
};
