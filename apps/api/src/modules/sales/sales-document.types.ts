export type SalesDocumentType =
  | 'estimate'
  | 'sale_order'
  | 'delivery_challan'
  | 'tax_invoice'
  | 'bill_of_supply'
  | 'normal_invoice'
  | 'pos'
  | 'sales_return';

export type DocumentStatus = 'draft' | 'finalized' | 'cancelled' | 'converted';

export type TaxType = 'cgst_sgst' | 'igst' | 'exempt' | 'none';

export type SalesDocumentLineRecord = {
  id: string;
  item_id: string;
  quantity: string;
  unit: string;
  unit_price: string;
  market_price: string | null;
  discount_amount: string;
  tax_type: TaxType;
  tax_rate: string;
  cgst_amount: string;
  sgst_amount: string;
  igst_amount: string;
  line_total: string;
  sort_order: number;
};

export type SalesDocumentRecord = {
  id: string;
  document_type: SalesDocumentType;
  status: DocumentStatus;
  document_number: string | null;
  document_series: string;
  party_id: string | null;
  is_gst_formal: boolean;
  party_state_code: string | null;
  subtotal: string;
  discount_total: string;
  tax_amount: string;
  total_amount: string;
  paid_amount: string;
  payment_mode: string | null;
  document_date: string;
  converted_from_id: string | null;
  pos_session_id: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
  lines?: SalesDocumentLineRecord[];
};

export type SalesDocumentsListSummary = {
  total_amount: string;
  received_amount: string;
  balance_amount: string;
};

export type ListSalesDocumentsFilterParams = {
  businessId: string;
  documentType?: SalesDocumentType;
  status?: DocumentStatus;
  partyId?: string;
  posSessionId?: string;
  from?: Date;
  to?: Date;
  q?: string;
  sort: 'document_date' | 'created_at' | 'document_number';
  order: 'asc' | 'desc';
};

export type ListSalesDocumentsParams = ListSalesDocumentsFilterParams & {
  page: number;
  limit: number;
};

export type SalesDocumentInsertValues = {
  businessId: string;
  documentType: SalesDocumentType;
  documentSeries: string;
  partyId?: string | null;
  isGstFormal?: boolean;
  partyStateCode?: string | null;
  documentDate?: Date;
  convertedFromId?: string | null;
  posSessionId?: string | null;
  notes?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type SalesDocumentUpdateValues = {
  partyId?: string | null;
  isGstFormal?: boolean;
  partyStateCode?: string | null;
  documentDate?: Date;
  notes?: string | null;
  documentSeries?: string;
  updatedBy?: string | null;
};

export type SalesLineInsertValues = {
  businessId: string;
  salesDocumentId: string;
  itemId: string;
  quantity: string;
  unit: string;
  unitPrice: string;
  marketPrice?: string | null;
  discountAmount?: string;
  taxType?: TaxType;
  taxRate?: string;
  cgstAmount?: string;
  sgstAmount?: string;
  igstAmount?: string;
  lineTotal: string;
  sortOrder?: number;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type SalesLineUpdateValues = {
  itemId?: string;
  quantity?: string;
  unit?: string;
  unitPrice?: string;
  marketPrice?: string | null;
  discountAmount?: string;
  taxType?: TaxType;
  taxRate?: string;
  cgstAmount?: string;
  sgstAmount?: string;
  igstAmount?: string;
  lineTotal?: string;
  sortOrder?: number;
  updatedBy?: string | null;
};

export type PaginatedSalesDocumentsResponse = {
  data: SalesDocumentRecord[];
  meta: { page: number; limit: number; total: number };
};

export type FinalizeSalesDocumentResponse = {
  success: boolean;
  message: string;
  document_number: string | null;
  status: DocumentStatus;
};

export type PosSessionRecord = {
  id: string;
  user_id: string;
  started_at: string;
  ended_at: string | null;
  opening_cash: string | null;
  closing_cash: string | null;
  created_at: string;
  updated_at: string;
};
