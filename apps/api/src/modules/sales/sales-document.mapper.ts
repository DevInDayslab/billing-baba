import type {
  SalesDocumentLineRecord,
  SalesDocumentRecord,
  SupplyType,
  TaxType,
} from './sales-document.types';

type DocumentRow = {
  id: string;
  documentType: string;
  status: string;
  documentNumber: string | null;
  documentSeries: string;
  partyId: string | null;
  isGstFormal: boolean;
  partyStateCode: string | null;
  subtotal: string;
  discountTotal: string;
  taxAmount: string;
  totalAmount: string;
  documentDate: Date;
  convertedFromId: string | null;
  originalDocumentId: string | null;
  originalDocumentNumber: string | null;
  originalDocumentDate: Date | null;
  supplyType: SupplyType;
  posSessionId: string | null;
  notes: string | null;
  createdBy: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type DocumentListMetadata = {
  createdByName?: string | null;
  godownName?: string | null;
};

type LineRow = {
  id: string;
  itemId: string;
  quantity: string;
  unit: string;
  unitPrice: string;
  marketPrice: string | null;
  discountAmount: string;
  taxType: string;
  taxRate: string;
  cgstAmount: string;
  sgstAmount: string;
  igstAmount: string;
  cessRate: string;
  cessAmount: string;
  lineTotal: string;
  sortOrder: number;
};

export function toSalesDocumentLineRecord(
  row: LineRow,
): SalesDocumentLineRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    quantity: row.quantity,
    unit: row.unit,
    unit_price: row.unitPrice,
    market_price: row.marketPrice,
    discount_amount: row.discountAmount,
    tax_type: row.taxType as TaxType,
    tax_rate: row.taxRate,
    cgst_amount: row.cgstAmount,
    sgst_amount: row.sgstAmount,
    igst_amount: row.igstAmount,
    cess_rate: row.cessRate ?? '0',
    cess_amount: row.cessAmount ?? '0',
    line_total: row.lineTotal,
    sort_order: row.sortOrder,
  };
}

type DocumentRowWithPayments = DocumentRow & {
  paidAmount?: string | number | null;
  paymentMode?: string | null;
};

export function toSalesDocumentRecord(
  row: DocumentRowWithPayments,
  lines?: LineRow[],
  metadata: DocumentListMetadata = {},
): SalesDocumentRecord {
  return {
    id: row.id,
    document_type: row.documentType as SalesDocumentRecord['document_type'],
    status: row.status as SalesDocumentRecord['status'],
    document_number: row.documentNumber,
    document_series: row.documentSeries,
    party_id: row.partyId,
    is_gst_formal: row.isGstFormal,
    party_state_code: row.partyStateCode,
    subtotal: row.subtotal,
    discount_total: row.discountTotal,
    tax_amount: row.taxAmount,
    total_amount: row.totalAmount,
    paid_amount: row.paidAmount == null ? '0' : String(row.paidAmount),
    payment_mode: row.paymentMode ?? null,
    document_date: row.documentDate.toISOString(),
    converted_from_id: row.convertedFromId,
    original_document_id: row.originalDocumentId,
    original_document_number: row.originalDocumentNumber,
    original_document_date: row.originalDocumentDate?.toISOString() ?? null,
    supply_type: row.supplyType ?? 'domestic',
    pos_session_id: row.posSessionId,
    notes: row.notes,
    created_by: row.createdBy,
    created_by_name: metadata.createdByName ?? null,
    godown_name: metadata.godownName ?? null,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
    ...(lines ? { lines: lines.map(toSalesDocumentLineRecord) } : {}),
  };
}
