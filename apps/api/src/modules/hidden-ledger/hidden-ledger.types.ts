export type HiddenLedgerEntryStatus = 'pending' | 'partial' | 'recovered';

export type HiddenLedgerEntryRecord = {
  id: string;
  party_id: string;
  party_name?: string;
  sale_id: string | null;
  invoice_id: string | null;
  invoice_number?: string | null;
  amount: string;
  recovered_amount: string;
  remaining_amount: string;
  status: HiddenLedgerEntryStatus;
  created_by: string | null;
  created_at: string;
};

export type HiddenLedgerEntryDetailRecord = HiddenLedgerEntryRecord & {
  recoveries: HiddenLedgerRecoveryRecord[];
};

export type HiddenLedgerRecoveryRecord = {
  id: string;
  ledger_entry_id: string;
  sale_id: string | null;
  recovered_amount: string;
  recovered_by: string | null;
  created_at: string;
};

export type HiddenLedgerPartySummary = {
  party_id: string;
  hidden_ledger_balance: string;
  pending_entries: number;
  total_remaining: string;
};

export type CreateHiddenLedgerEntryValues = {
  businessId: string;
  partyId: string;
  saleId?: string | null;
  invoiceId?: string | null;
  amount: string;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type CreateHiddenLedgerRecoveryValues = {
  businessId: string;
  ledgerEntryId: string;
  saleId?: string | null;
  recoveredAmount: string;
  recoveredBy?: string | null;
};
