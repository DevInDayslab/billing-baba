import { z } from 'zod';

const nullableString = z.string().trim().nullable().optional();
const nullableNumber = z.number().nullable().optional();
const nullableBoolean = z.boolean().nullable().optional();

export const parsedPurchaseDocumentLineSchema = z.object({
  item_name: nullableString,
  item_id: nullableString,
  description: nullableString,
  quantity: nullableNumber,
  unit: nullableString,
  unit_price: nullableNumber,
  tax_rate: nullableNumber,
  tax_inclusive: nullableBoolean,
  tax_amount: nullableNumber,
  discount_amount: nullableNumber,
});

export const parsedPurchaseDocumentSchema = z.object({
  vendor_name: nullableString,
  party_id: nullableString,
  gstin: nullableString,
  vendor_phone: nullableString,
  vendor_email: nullableString,
  vendor_address: nullableString,
  vendor_city: nullableString,
  vendor_pincode: nullableString,
  vendor_state: nullableString,
  supplier_invoice_number: nullableString,
  invoice_number: nullableString,
  invoice_date: nullableString,
  due_date: nullableString,
  state_of_supply: nullableString,
  payment_mode: nullableString,
  payment_amount: nullableNumber,
  notes: nullableString,
  terms_notes: nullableString,
  subtotal: nullableNumber,
  discount_total: nullableNumber,
  tax_amount: nullableNumber,
  total_amount: nullableNumber,
  lines: z.array(parsedPurchaseDocumentLineSchema).optional().default([]),
});

export const ALLOWED_PARSE_EXTENSIONS = new Set([
  'jpg',
  'jpeg',
  'png',
  'pdf',
]);

export const ALLOWED_PARSE_MIME_TYPES = new Set([
  'image/jpeg',
  'image/jpg',
  'image/png',
  'application/pdf',
]);
