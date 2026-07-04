export type DashboardDateRange = {
  period: string;
  from: string;
  to: string;
};

export type DashboardOverview = {
  total_receivable: string;
  receivable_party_count: number;
  total_payable: string;
  payable_party_count: number;
};

export type DashboardSalesSummary = {
  total_amount: string;
  invoice_count: number;
  received_amount: string;
  balance_amount: string;
};

export type DashboardPurchaseSummary = {
  total_amount: string;
  bill_count: number;
};

export type DashboardFinanceSummary = {
  cash_in: string;
  cash_out: string;
  expenses: string;
};

export type DashboardLowStockItem = {
  item_id: string;
  item_name: string;
  quantity: string;
  reorder_level: string;
};

export type DashboardInventorySummary = {
  total_stock_value: string;
  low_stock_count: number;
  negative_stock_count: number;
  low_stock_items: DashboardLowStockItem[];
};

export type DashboardTrendPoint = {
  date: string;
  amount: string;
};

export type DashboardCharts = {
  sales_trend: {
    granularity: 'day';
    points: DashboardTrendPoint[];
  };
  purchases_trend: {
    granularity: 'day';
    points: DashboardTrendPoint[];
  };
};

export type DashboardRecentTransaction = {
  id: string;
  type: 'sale' | 'purchase' | 'payment' | 'expense';
  reference_number: string | null;
  party_name: string | null;
  amount: string;
  date: string;
};

export type DashboardQuickReport = {
  key: string;
  title: string;
  route: string;
};

export type DashboardPayload = {
  generated_at: string;
  period: DashboardDateRange;
  overview: DashboardOverview;
  sales: DashboardSalesSummary;
  purchases: DashboardPurchaseSummary;
  finance: DashboardFinanceSummary;
  inventory: DashboardInventorySummary;
  charts: DashboardCharts;
  alerts: [];
  recent_transactions: DashboardRecentTransaction[];
  top_parties: {
    top_customer: null;
    top_supplier: null;
  };
  quick_reports: DashboardQuickReport[];
};
