import type {
  DocumentStatus,
  TaxType,
} from '../../shared/documents/document.types';

export type PurchaseDocumentType =
  | 'purchase_order'
  | 'purchase_bill'
  | 'purchase_return';

export type { DocumentStatus, TaxType };

export type PurchaseDocumentLineRecord = {
  id: string;
  item_id: string;
  quantity: string;
  unit: string;
  unit_price: string;
  discount_amount: string;
  tax_type: TaxType;
  tax_rate: string;
  cgst_amount: string;
  sgst_amount: string;
  igst_amount: string;
  line_total: string;
  sort_order: number;
};

export type PurchaseDocumentRecord = {
  id: string;
  document_type: PurchaseDocumentType;
  status: DocumentStatus;
  document_number: string | null;
  document_series: string;
  party_id: string;
  is_gst_formal: boolean;
  party_state_code: string | null;
  subtotal: string;
  discount_total: string;
  tax_amount: string;
  total_amount: string;
  document_date: string;
  converted_from_id: string | null;
  supplier_invoice_number: string | null;
  due_date: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
  lines?: PurchaseDocumentLineRecord[];
};

export type ListPurchaseDocumentsParams = {
  businessId: string;
  page: number;
  limit: number;
  documentType?: PurchaseDocumentType;
  status?: DocumentStatus;
  partyId?: string;
  from?: Date;
  to?: Date;
  q?: string;
  sort: 'document_date' | 'created_at' | 'document_number';
  order: 'asc' | 'desc';
};

export type PurchaseDocumentInsertValues = {
  businessId: string;
  documentType: PurchaseDocumentType;
  documentSeries: string;
  partyId: string;
  isGstFormal?: boolean;
  partyStateCode?: string | null;
  documentDate?: Date;
  convertedFromId?: string | null;
  supplierInvoiceNumber?: string | null;
  dueDate?: string | null;
  notes?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type PurchaseDocumentUpdateValues = {
  partyId?: string;
  isGstFormal?: boolean;
  partyStateCode?: string | null;
  documentDate?: Date;
  documentSeries?: string;
  supplierInvoiceNumber?: string | null;
  dueDate?: string | null;
  notes?: string | null;
  updatedBy?: string | null;
};

export type PurchaseLineInsertValues = {
  businessId: string;
  purchaseDocumentId: string;
  itemId: string;
  quantity: string;
  unit: string;
  unitPrice: string;
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

export type PurchaseLineUpdateValues = {
  itemId?: string;
  quantity?: string;
  unit?: string;
  unitPrice?: string;
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

export type FinalizePurchaseDocumentResponse = {
  success: boolean;
  message: string;
  document_number: string | null;
  status: DocumentStatus;
};
