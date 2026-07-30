export type PurchaseFaAssetRecord = {
  id: string;
  asset_name: string;
  asset_category: string | null;
  serial_number: string | null;
  purchase_price: string;
  location: string | null;
  warranty_expiry: string | null;
  description: string | null;
  qty: string;
  tax_rate: string;
  tax_amount: string;
  line_total: string;
  sort_order: number;
  purchase_document_id: string | null;
};

export type PurchaseFaBatchRecord = {
  id: string;
  party_id: string;
  party_name: string;
  reference_number: string | null;
  purchase_date: string;
  due_date: string | null;
  payment_mode: string | null;
  subtotal: string;
  tax_amount: string;
  total_amount: string;
  balance_due: string;
  status: string;
  notes: string | null;
  description: string | null;
  assets: PurchaseFaAssetRecord[];
  created_at: string;
  updated_at: string;
};

export type PurchaseFaBatchListRecord = {
  id: string;
  party_id: string;
  party_name: string;
  reference_number: string | null;
  purchase_date: string;
  due_date: string | null;
  payment_mode: string | null;
  total_amount: string;
  balance_due: string;
  status: string;
  created_at: string;
  updated_at: string;
};

export type PurchaseFaAssetInput = {
  id?: string;
  asset_name: string;
  asset_category?: string | null;
  serial_number?: string | null;
  purchase_price: string;
  location?: string | null;
  warranty_expiry?: string | null;
  description?: string | null;
  qty?: string;
  tax_rate?: string;
  tax_amount?: string;
  line_total: string;
  sort_order?: number;
  purchase_document_id?: string | null;
};

export type ListPurchaseFaParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  partyId?: string;
  status?: string;
  from?: string;
  to?: string;
  sort: 'purchase_date' | 'created_at' | 'total_amount';
  order: 'asc' | 'desc';
};
