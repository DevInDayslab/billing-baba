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

export type ReportBillWiseProfitRow = {
  date: string;
  invoice_no: string;
  party_name: string | null;
  sale_amount: string;
  purchase_amount: string;
  profit: string;
};

export type ReportPartyWiseProfitLossRow = {
  party_name: string;
  phone: string | null;
  sale_amount: string;
  purchase_amount: string;
  profit: string;
};

export type ReportSalePurchaseByPartyRow = {
  party_name: string;
  sale_amount: string;
  purchase_amount: string;
};

export type ReportSalePurchaseByPartyGroupRow = {
  party_group: string;
  party_name: string;
  sale_amount: string;
  purchase_amount: string;
};

export type ReportPartyByItemRow = {
  party_name: string;
  quantity: string;
  amount: string;
};

export type ReportGstr9SupplyRow = {
  label: string;
  taxable_value: string;
  integrated_tax: string;
  central_tax: string;
  state_tax: string;
  cess: string;
};

export type ReportHsnRow = {
  hsn: string;
  description: string;
  uqc: string;
  quantity: string;
  total_value: string;
  taxable_value: string;
  igst: string;
  cgst: string;
  sgst: string;
};

export type ReportSacRow = {
  sac: string;
  invoice_type: string;
  total_value: string;
  taxable_value: string;
  igst: string;
  cgst: string;
  sgst: string;
  cess: string;
};

export type ReportItemByPartyRow = {
  item_name: string;
  party_name: string;
  quantity: string;
  amount: string;
};

export type ReportItemWiseProfitLossRow = {
  item_name: string;
  sale_amount: string;
  purchase_amount: string;
  profit: string;
};

export type ReportStockDetailRow = {
  item_name: string;
  opening_qty: string;
  in_qty: string;
  out_qty: string;
  closing_qty: string;
};

export type ReportItemDetailRow = {
  date: string;
  type: string;
  ref_no: string;
  party_name: string | null;
  quantity: string;
  price: string;
  amount: string;
};

export type ReportCategoryAmountRow = {
  category: string;
  sale_amount: string;
  purchase_amount: string;
};

export type ReportItemDiscountRow = {
  item_name: string;
  sale_qty: string;
  discount_amount: string;
  discount_percent: string;
};

export type ReportManufacturingRow = {
  date: string;
  ref_no: string;
  item_name: string;
  quantity: string;
  cost: string;
};

export type ReportConsumptionRow = {
  date: string;
  ref_no: string;
  item_name: string;
  quantity: string;
  value: string;
};

export type ReportStockTransferRow = {
  date: string;
  ref_no: string;
  from_godown: string;
  to_godown: string;
  item_name: string;
  quantity: string;
};

export type ReportExpenseRow = {
  date: string;
  expense_no: string;
  party_name: string | null;
  category: string;
  amount: string;
  due_date: string;
  status: string;
};

export type ReportExpenseCategoryRow = {
  category: string;
  amount: string;
  count: number;
};

export type ReportExpenseItemRow = {
  item_name: string;
  category: string;
  amount: string;
  count: number;
};

export type ReportBankStatementRow = {
  date: string;
  description: string;
  ref_no: string;
  money_in: string;
  money_out: string;
  balance: string;
  is_opening: boolean;
};

export type ReportOrderRow = {
  date: string;
  order_no: string;
  party_name: string;
  due_date: string;
  status: string;
  type: string;
  amount: string;
};

export type ReportOrderItemRow = {
  item_name: string;
  order_no: string;
  party_name: string;
  quantity: string;
  amount: string;
};

export type ReportGstTaxPartyRow = {
  party_name: string;
  sale_tax: string;
  purchase_expense_tax: string;
};

export type ReportGstTaxRateRow = {
  tax_name: string;
  tax_percent: string;
  taxable_sale_amount: string;
  tax_in: string;
  taxable_purchase_expense_amount: string;
  tax_out: string;
};

export type ReportOtherIncomeRow = {
  date: string;
  income_no: string;
  party_name: string | null;
  category: string;
  payment_type: string | null;
  amount: string;
  due_date: string;
  status: string;
};

export type ReportOtherIncomeCategoryRow = {
  category: string;
  amount: string;
  count: number;
};

export type ReportOtherIncomeItemRow = {
  item_name: string;
  category: string;
  amount: string;
  count: number;
};

export type ReportLoanStatementRow = {
  date: string;
  description: string | null;
  ref_no: string;
  debit: string;
  credit: string;
  balance: string;
  is_opening: boolean;
};

export type BillWiseProfitPayload = {
  period: ReportPeriodMeta;
  total_profit: string;
  rows: ReportBillWiseProfitRow[];
};

export type CashFlowPayload = {
  period: ReportPeriodMeta;
  opening_cash: string;
  closing_cash: string;
  total_cash_in: string;
  total_cash_out: string;
  rows: ReportTransactionRow[];
};

export type Gstr9Payload = {
  period: ReportPeriodMeta;
  rows: ReportGstr9SupplyRow[];
};

export type BankStatementPayload = {
  period: ReportPeriodMeta;
  bank_name: string | null;
  rows: ReportBankStatementRow[];
};

export type LoanStatementPayload = {
  period: ReportPeriodMeta;
  loan_account: string;
  party_id: string;
  rows: ReportLoanStatementRow[];
};

export type PaginatedRowsPayload<T> = {
  period?: ReportPeriodMeta;
  rows: T[];
  [key: string]: unknown;
};

export type ReportTrialBalanceRow = {
  account_name: string;
  opening: string;
  debit: string;
  credit: string;
  closing: string;
  balance_type: 'debit' | 'credit';
};

export type TrialBalancePayload = {
  period: ReportPeriodMeta;
  rows: ReportTrialBalanceRow[];
  total_debit: string;
  total_credit: string;
  is_balanced: boolean;
};

export type ReportBalanceSheetItem = {
  name: string;
  amount: string;
  indent: number;
  is_header: boolean;
};

export type BalanceSheetPayload = {
  period: ReportPeriodMeta;
  as_on: string;
  assets: ReportBalanceSheetItem[];
  liabilities: ReportBalanceSheetItem[];
  assets_total: string;
  liabilities_total: string;
  net_profit: string;
  opening_assets: string;
  closing_assets: string;
  opening_liabilities: string;
  closing_liabilities: string;
  opening_equity: string;
  closing_equity: string;
  is_balanced: boolean;
};
