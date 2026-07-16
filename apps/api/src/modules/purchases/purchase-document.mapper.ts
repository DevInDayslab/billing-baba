import type {
  PurchaseDocumentLineRecord,
  PurchaseDocumentRecord,
  TaxType,
} from './purchase-document.types';

type DocumentRow = {
  id: string;
  documentType: string;
  status: string;
  documentNumber: string | null;
  documentSeries: string;
  partyId: string;
  isGstFormal: boolean;
  partyStateCode: string | null;
  subtotal: string;
  discountTotal: string;
  taxAmount: string;
  totalAmount: string;
  documentDate: Date;
  convertedFromId: string | null;
  supplierInvoiceNumber: string | null;
  dueDate: string | null;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type DocumentRowWithPayments = DocumentRow & {
  paidAmount?: string | number | null;
  paymentMode?: string | null;
};

type LineRow = {
  id: string;
  itemId: string;
  quantity: string;
  unit: string;
  unitPrice: string;
  discountAmount: string;
  taxType: string;
  taxRate: string;
  cgstAmount: string;
  sgstAmount: string;
  igstAmount: string;
  lineTotal: string;
  sortOrder: number;
};

export function toPurchaseDocumentLineRecord(
  row: LineRow,
): PurchaseDocumentLineRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    quantity: row.quantity,
    unit: row.unit,
    unit_price: row.unitPrice,
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

export function toPurchaseDocumentRecord(
  row: DocumentRowWithPayments,
  lines?: LineRow[],
): PurchaseDocumentRecord {
  return {
    id: row.id,
    document_type: row.documentType as PurchaseDocumentRecord['document_type'],
    status: row.status as PurchaseDocumentRecord['status'],
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
    supplier_invoice_number: row.supplierInvoiceNumber,
    due_date: row.dueDate,
    notes: row.notes,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
    ...(lines ? { lines: lines.map(toPurchaseDocumentLineRecord) } : {}),
  };
}
