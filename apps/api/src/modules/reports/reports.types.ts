export type ReportPeriodMeta = {
  period: string;
  from: string;
  to: string;
};

export type ReportAmountSummary = {
  total_amount: string;
  received_amount?: string;
  balance_amount?: string;
  paid_amount?: string;
  count: number;
};

export type ReportSaleRow = {
  id: string;
  document_number: string;
  document_date: string;
  party_id: string | null;
  party_name: string | null;
  document_type: string;
  payment_mode: string | null;
  status: string;
  total_amount: string;
  balance_amount: string;
};

export type ReportPurchaseRow = {
  id: string;
  document_number: string;
  document_date: string;
  party_id: string;
  party_name: string;
  payment_mode: string | null;
  status: string;
  total_amount: string;
  balance_amount: string;
};

export type ReportStockSummaryRow = {
  item_id: string;
  item_name: string;
  category_id: string | null;
  stock_qty: string;
  average_cost: string;
  stock_value: string;
  sale_price: string | null;
};

export type ReportLowStockRow = {
  item_id: string;
  item_name: string;
  current_stock: string;
  min_stock: string;
  shortage: string;
};

export type ReportPartyOutstandingRow = {
  party_id: string;
  party_name: string;
  phone: string | null;
  email: string | null;
  balance: string;
  balance_type: 'receivable' | 'payable' | 'settled';
};

export type ReportPartyOutstandingSummary = {
  total_receivable: string;
  receivable_party_count: number;
  total_payable: string;
  payable_party_count: number;
};

export type ReportPartyStatementEntry = {
  id: string;
  date: string;
  type: string;
  ref_no: string;
  description: string | null;
  debit: string;
  credit: string;
  balance: string;
};

export type ReportPartyStatementSummary = {
  total_sale: string;
  total_purchase: string;
  total_money_in: string;
  total_money_out: string;
  total_receivable: string;
};

export type ReportTransactionRow = {
  id: string;
  date: string;
  ref_no: string;
  party_id: string | null;
  party_name: string | null;
  category: string;
  type: string;
  total: string;
  received: string;
  balance: string;
  money_in: string;
  money_out: string;
  status: string;
  payment_type: string | null;
};

export type ReportProfitLossItem = {
  particular: string;
  amount: string;
  is_header: boolean;
  indent: number;
};

export type ReportGstrRow = {
  gstin: string | null;
  party_name: string | null;
  invoice_no: string;
  date: string;
  value: string;
  tax_rate: string;
  taxable_value: string;
  integrated_tax: string;
  central_tax: string;
  state_tax: string;
  cess: string;
};

export type ReportGstr3bRow = {
  nature: string;
  taxable_value: string;
  integrated_tax: string;
  central_tax: string;
  state_tax: string;
  cess: string;
};

export type SaleReportPayload = {
  period: ReportPeriodMeta;
  summary: ReportAmountSummary;
  rows: ReportSaleRow[];
};

export type PurchaseReportPayload = {
  period: ReportPeriodMeta;
  summary: ReportAmountSummary;
  rows: ReportPurchaseRow[];
};

export type StockSummaryPayload = {
  total_stock_value: string;
  rows: ReportStockSummaryRow[];
};

export type LowStockPayload = {
  low_stock_count: number;
  rows: ReportLowStockRow[];
};

export type PartyOutstandingPayload = {
  summary: ReportPartyOutstandingSummary;
  rows: ReportPartyOutstandingRow[];
};

export type PartyStatementPayload = {
  period: ReportPeriodMeta;
  party_id: string;
  summary: ReportPartyStatementSummary;
  entries: ReportPartyStatementEntry[];
};

export type DayBookPayload = {
  date: string;
  total_money_in: string;
  total_money_out: string;
  net_total: string;
  rows: ReportTransactionRow[];
};

export type AllTransactionsPayload = {
  period: ReportPeriodMeta;
  rows: ReportTransactionRow[];
};

export type ProfitLossPayload = {
  period: ReportPeriodMeta;
  net_profit: string;
  items: ReportProfitLossItem[];
};

export type GstrReportPayload = {
  period: ReportPeriodMeta;
  rows: ReportGstrRow[];
};

export type Gstr3bPayload = {
  period: ReportPeriodMeta;
  rows: ReportGstr3bRow[];
};
