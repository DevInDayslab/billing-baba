export type OutstandingSummary = {
  total_receivable: string;
  receivable_party_count: number;
  total_payable: string;
  payable_party_count: number;
};

export type PartyOutstandingBalance = {
  party_id: string;
  balance: string;
};
