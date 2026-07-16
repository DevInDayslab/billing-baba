export type ParsedPurchaseDocumentLine = {
  item_name: string | null;
  item_id: string | null;
  description: string | null;
  quantity: number | null;
  unit: string | null;
  unit_price: number | null;
  tax_rate: number | null;
  tax_inclusive: boolean | null;
  tax_amount: number | null;
  discount_amount: number | null;
};

export type ParsedPurchaseDocument = {
  vendor_name: string | null;
  party_id: string | null;
  gstin: string | null;
  vendor_phone: string | null;
  vendor_email: string | null;
  vendor_address: string | null;
  vendor_city: string | null;
  vendor_pincode: string | null;
  vendor_state: string | null;
  supplier_invoice_number: string | null;
  invoice_number: string | null;
  invoice_date: string | null;
  due_date: string | null;
  state_of_supply: string | null;
  payment_mode: string | null;
  payment_amount: number | null;
  notes: string | null;
  terms_notes: string | null;
  subtotal: number | null;
  discount_total: number | null;
  tax_amount: number | null;
  total_amount: number | null;
  lines: ParsedPurchaseDocumentLine[];
};

export type ParseDocumentInput = {
  buffer: Buffer;
  filename: string;
  mimeType: string;
};
