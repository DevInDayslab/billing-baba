export type SaleFaAssetRecord = {
  id: string;
  asset_name: string;
  item_code: string | null;
  asset_category: string | null;
  serial_number: string | null;
  sale_price: string;
  location: string | null;
  description: string | null;
  qty: string;
  tax_rate: string;
  tax_amount: string;
  line_total: string;
  sort_order: number;
  purchase_fixed_asset_id: string | null;
};

export type SaleFaBatchRecord = {
  id: string;
  party_id: string;
  party_name: string;
  reference_number: string | null;
  sale_date: string;
  due_date: string | null;
  payment_mode: string | null;
  subtotal: string;
  tax_amount: string;
  total_amount: string;
  balance_due: string;
  status: string;
  notes: string | null;
  description: string | null;
  assets: SaleFaAssetRecord[];
  created_at: string;
  updated_at: string;
};

export type SaleFaBatchListRecord = {
  id: string;
  party_id: string;
  party_name: string;
  reference_number: string | null;
  sale_date: string;
  due_date: string | null;
  payment_mode: string | null;
  total_amount: string;
  balance_due: string;
  status: string;
  created_at: string;
  updated_at: string;
};

export type SaleFaAssetInput = {
  id?: string;
  asset_name: string;
  item_code?: string | null;
  asset_category?: string | null;
  serial_number?: string | null;
  sale_price: string;
  location?: string | null;
  description?: string | null;
  qty?: string;
  tax_rate?: string;
  tax_amount?: string;
  line_total: string;
  sort_order?: number;
  purchase_fixed_asset_id?: string | null;
};

export type ListSaleFaParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  partyId?: string;
  status?: string;
  from?: string;
  to?: string;
  sort: 'sale_date' | 'created_at' | 'total_amount';
  order: 'asc' | 'desc';
};
