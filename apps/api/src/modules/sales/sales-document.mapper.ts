import type {
  SalesDocumentLineRecord,
  SalesDocumentRecord,
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
  posSessionId: string | null;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
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
  lineTotal: string;
  sortOrder: number;
};

export function toSalesDocumentLineRecord(row: LineRow): SalesDocumentLineRecord {
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
    line_total: row.lineTotal,
    sort_order: row.sortOrder,
  };
}

export function toSalesDocumentRecord(
  row: DocumentRow,
  lines?: LineRow[],
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
    document_date: row.documentDate.toISOString(),
    converted_from_id: row.convertedFromId,
    pos_session_id: row.posSessionId,
    notes: row.notes,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
    ...(lines ? { lines: lines.map(toSalesDocumentLineRecord) } : {}),
  };
}
