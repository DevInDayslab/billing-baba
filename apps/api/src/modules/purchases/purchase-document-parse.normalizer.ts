import { z } from 'zod';
import {
  parsedPurchaseDocumentLineSchema,
  parsedPurchaseDocumentSchema,
} from './purchase-document-parse.schema';
import {
  logFlattenedDocument,
  logJsonParseError,
  logNormalizationInput,
  logNormalizedDocument,
  logValidationOrMappingError,
} from './purchase-document-parse.debug';
import type { ParsedPurchaseDocument } from './purchase-document-parse.types';

const PAYMENT_MODE_ALIASES: Record<string, string> = {
  cash: 'cash',
  credit: 'other',
  upi: 'upi',
  cheque: 'cheque',
  check: 'cheque',
  'bank transfer': 'bank_transfer',
  bank_transfer: 'bank_transfer',
  neft: 'bank_transfer',
  rtgs: 'bank_transfer',
  imps: 'bank_transfer',
  card: 'card',
  debit: 'card',
  credit_card: 'card',
  online: 'upi',
  wallet: 'other',
  others: 'other',
  other: 'other',
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function pickString(
  record: Record<string, unknown>,
  keys: string[],
): string | null {
  for (const key of keys) {
    const value = record[key];
    if (typeof value === 'string' && value.trim()) {
      return value.trim();
    }
    if (typeof value === 'number' && Number.isFinite(value)) {
      return String(value);
    }
  }
  return null;
}

function pickNumber(
  record: Record<string, unknown>,
  keys: string[],
): number | null {
  for (const key of keys) {
    const normalized = normalizeNumber(record[key]);
    if (normalized != null) {
      return normalized;
    }
  }
  return null;
}

function pickBoolean(
  record: Record<string, unknown>,
  keys: string[],
): boolean | null {
  for (const key of keys) {
    const normalized = normalizeBoolean(record[key]);
    if (normalized != null) {
      return normalized;
    }
  }
  return null;
}

export function normalizeNumber(value: unknown): number | null {
  if (value == null || value === '') return null;
  if (typeof value === 'number' && Number.isFinite(value)) return value;
  if (typeof value !== 'string') return null;

  const cleaned = value
    .trim()
    .replace(/[₹$,]/g, '')
    .replace(/\s+/g, '')
    .replace(/[^0-9.\-]/g, '');
  if (!cleaned) return null;

  const parsed = Number.parseFloat(cleaned);
  return Number.isFinite(parsed) ? parsed : null;
}

export function normalizeBoolean(value: unknown): boolean | null {
  if (value == null || value === '') return null;
  if (typeof value === 'boolean') return value;
  if (typeof value === 'number') return value !== 0;
  if (typeof value !== 'string') return null;

  const normalized = value.trim().toLowerCase();
  if (['true', 'yes', 'y', '1'].includes(normalized)) return true;
  if (['false', 'no', 'n', '0'].includes(normalized)) return false;
  return null;
}

export function normalizeDate(value: unknown): string | null {
  if (value == null || value === '') return null;
  if (value instanceof Date && !Number.isNaN(value.getTime())) {
    return formatDateParts(
      value.getFullYear(),
      value.getMonth() + 1,
      value.getDate(),
    );
  }

  const text = String(value).trim();
  if (!text) return null;

  const isoMatch = text.match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (isoMatch) {
    return formatDateParts(
      Number(isoMatch[1]),
      Number(isoMatch[2]),
      Number(isoMatch[3]),
    );
  }

  const dmy = text.match(/^(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})$/);
  if (dmy) {
    const day = Number(dmy[1]);
    const month = Number(dmy[2]);
    let year = Number(dmy[3]);
    if (year < 100) year += 2000;
    return formatDateParts(year, month, day);
  }

  const parsed = new Date(text);
  if (Number.isNaN(parsed.getTime())) return null;
  return formatDateParts(
    parsed.getFullYear(),
    parsed.getMonth() + 1,
    parsed.getDate(),
  );
}

function formatDateParts(
  year: number,
  month: number,
  day: number,
): string | null {
  if (
    !Number.isFinite(year) ||
    !Number.isFinite(month) ||
    !Number.isFinite(day)
  ) {
    return null;
  }
  const date = new Date(Date.UTC(year, month - 1, day));
  if (
    date.getUTCFullYear() !== year ||
    date.getUTCMonth() !== month - 1 ||
    date.getUTCDate() !== day
  ) {
    return null;
  }
  return `${String(year).padStart(4, '0')}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

export function normalizeGstin(value: unknown): string | null {
  if (value == null || value === '') return null;
  const text = String(value).trim().toUpperCase().replace(/\s+/g, '');
  return text || null;
}

export function normalizePaymentMode(value: unknown): string | null {
  if (value == null || value === '') return null;
  const text = String(value).trim().toLowerCase().replace(/\s+/g, ' ');
  return PAYMENT_MODE_ALIASES[text] ?? null;
}

function normalizeLineTaxRate(raw: Record<string, unknown>): number | null {
  const direct = pickNumber(raw, [
    'tax_rate',
    'taxRate',
    'tax_percent',
    'gst_rate',
    'gst_percent',
  ]);
  if (direct != null && direct > 0) return direct;

  const cgst = pickNumber(raw, [
    'cgst_rate',
    'cgstRate',
    'cgst_percent',
    'cgst',
  ]);
  const sgst = pickNumber(raw, [
    'sgst_rate',
    'sgstRate',
    'sgst_percent',
    'sgst',
  ]);
  if (cgst != null && sgst != null) return cgst + sgst;
  if (cgst != null && cgst > 0) return cgst * 2;
  if (sgst != null && sgst > 0) return sgst * 2;

  const igst = pickNumber(raw, [
    'igst_rate',
    'igstRate',
    'igst_percent',
    'igst',
  ]);
  if (igst != null && igst > 0) return igst;

  return null;
}

function normalizeLine(raw: unknown): Record<string, unknown> | null {
  if (!isRecord(raw)) return null;

  const itemName = pickString(raw, [
    'item_name',
    'itemName',
    'name',
    'product',
    'product_name',
    'description',
  ]);
  if (!itemName) return null;

  return {
    item_name: itemName,
    item_id: pickString(raw, ['item_id', 'itemId']),
    description: pickString(raw, [
      'description',
      'item_description',
      'details',
    ]),
    quantity: pickNumber(raw, ['quantity', 'qty', 'qnty']),
    unit: pickString(raw, ['unit', 'uom']),
    unit_price: pickNumber(raw, [
      'unit_price',
      'unitPrice',
      'price',
      'rate',
      'price_per_unit',
    ]),
    tax_rate: normalizeLineTaxRate(raw),
    tax_inclusive: pickBoolean(raw, [
      'tax_inclusive',
      'taxInclusive',
      'price_is_tax_inclusive',
    ]),
    tax_amount: pickNumber(raw, [
      'tax_amount',
      'taxAmount',
      'line_tax',
      'gst_amount',
      'total_tax',
    ]),
    discount_amount: pickNumber(raw, [
      'discount_amount',
      'discountAmount',
      'discount',
    ]),
  };
}

function flattenDocumentPayload(raw: unknown): Record<string, unknown> {
  if (!isRecord(raw)) return {};

  const nested =
    (isRecord(raw.data) && raw.data) ||
    (isRecord(raw.parsed) && raw.parsed) ||
    (isRecord(raw.invoice) && raw.invoice) ||
    raw;

  const linesSource = Array.isArray(nested.lines)
    ? nested.lines
    : Array.isArray(nested.items)
      ? nested.items
      : Array.isArray(nested.line_items)
        ? nested.line_items
        : [];

  const lines = linesSource
    .map((line) => normalizeLine(line))
    .filter((line): line is Record<string, unknown> => line != null);

  return {
    vendor_name: pickString(nested, [
      'vendor_name',
      'vendorName',
      'supplier',
      'supplier_name',
      'supplierName',
      'party',
      'party_name',
    ]),
    party_id: pickString(nested, ['party_id', 'partyId']),
    gstin: normalizeGstin(
      pickString(nested, ['gstin', 'gst_in', 'supplier_gstin', 'vendor_gstin']),
    ),
    vendor_phone: pickString(nested, [
      'vendor_phone',
      'vendorPhone',
      'vendor_mobile',
      'vendorMobile',
      'supplier_phone',
      'supplier_mobile',
      'phone',
      'mobile',
    ]),
    vendor_email: pickString(nested, [
      'vendor_email',
      'vendorEmail',
      'supplier_email',
      'email',
    ]),
    vendor_address: pickString(nested, [
      'vendor_address',
      'vendorAddress',
      'supplier_address',
      'address',
      'address_line',
      'billing_address',
    ]),
    vendor_city: pickString(nested, ['vendor_city', 'vendorCity', 'city']),
    vendor_pincode: pickString(nested, [
      'vendor_pincode',
      'vendorPincode',
      'pincode',
      'postal_code',
      'zip',
    ]),
    vendor_state: pickString(nested, [
      'vendor_state',
      'vendorState',
      'supplier_state',
    ]),
    supplier_invoice_number: pickString(nested, [
      'supplier_invoice_number',
      'supplierInvoiceNumber',
      'supplier_invoice_no',
      'vendor_invoice_number',
      'bill_no',
    ]),
    invoice_number: pickString(nested, [
      'invoice_number',
      'invoiceNumber',
      'invoice_no',
      'invoiceNo',
      'bill_number',
    ]),
    invoice_date: normalizeDate(
      pickString(nested, ['invoice_date', 'invoiceDate', 'bill_date', 'date']),
    ),
    due_date: normalizeDate(
      pickString(nested, ['due_date', 'dueDate', 'payment_due_date']),
    ),
    state_of_supply: pickString(nested, [
      'state_of_supply',
      'stateOfSupply',
      'place_of_supply',
      'state',
    ]),
    payment_mode: normalizePaymentMode(
      pickString(nested, ['payment_mode', 'paymentMode', 'payment_method']),
    ),
    payment_amount: pickNumber(nested, [
      'payment_amount',
      'paymentAmount',
      'amount_paid',
      'paid_amount',
    ]),
    notes: pickString(nested, ['notes', 'remarks', 'description']),
    terms_notes: pickString(nested, [
      'terms_notes',
      'termsNotes',
      'terms_and_conditions',
    ]),
    subtotal: pickNumber(nested, ['subtotal', 'sub_total', 'taxable_amount']),
    discount_total: pickNumber(nested, [
      'discount_total',
      'discountTotal',
      'discount',
      'total_discount',
    ]),
    tax_amount: pickNumber(nested, [
      'tax_amount',
      'taxAmount',
      'total_tax',
      'gst_amount',
    ]),
    total_amount: pickNumber(nested, [
      'total_amount',
      'totalAmount',
      'grand_total',
      'total',
      'invoice_total',
    ]),
    lines,
  };
}

export function normalizeParsedDocument(raw: unknown): ParsedPurchaseDocument {
  logNormalizationInput(raw);

  const flattened = flattenDocumentPayload(raw);
  logFlattenedDocument(flattened);

  let parsed;
  try {
    parsed = parsedPurchaseDocumentSchema.parse(flattened);
  } catch (error) {
    logValidationOrMappingError('Zod validation', error, flattened);
    throw error;
  }

  const document: ParsedPurchaseDocument = {
    vendor_name: parsed.vendor_name ?? null,
    party_id: parsed.party_id ?? null,
    gstin: parsed.gstin ?? null,
    vendor_phone: parsed.vendor_phone ?? null,
    vendor_email: parsed.vendor_email ?? null,
    vendor_address: parsed.vendor_address ?? null,
    vendor_city: parsed.vendor_city ?? null,
    vendor_pincode: parsed.vendor_pincode ?? null,
    vendor_state: parsed.vendor_state ?? null,
    supplier_invoice_number: parsed.supplier_invoice_number ?? null,
    invoice_number: parsed.invoice_number ?? null,
    invoice_date: parsed.invoice_date ?? null,
    due_date: parsed.due_date ?? null,
    state_of_supply: parsed.state_of_supply ?? null,
    payment_mode: parsed.payment_mode ?? null,
    payment_amount: parsed.payment_amount ?? null,
    notes: parsed.notes ?? null,
    terms_notes: parsed.terms_notes ?? null,
    subtotal: parsed.subtotal ?? null,
    discount_total: parsed.discount_total ?? null,
    tax_amount: parsed.tax_amount ?? null,
    total_amount: parsed.total_amount ?? null,
    lines: (parsed.lines ?? []).map((line) => ({
      item_name: line.item_name ?? null,
      item_id: line.item_id ?? null,
      description: line.description ?? null,
      quantity: line.quantity ?? null,
      unit: line.unit ?? null,
      unit_price: line.unit_price ?? null,
      tax_rate: line.tax_rate ?? null,
      tax_inclusive: line.tax_inclusive ?? null,
      tax_amount: line.tax_amount ?? null,
      discount_amount: line.discount_amount ?? null,
    })),
  };

  logNormalizedDocument(document);
  return document;
}

export function extractJsonFromText(text: string): unknown {
  const trimmed = text.trim();
  if (!trimmed) {
    throw new Error('Gemini returned an empty response');
  }

  try {
    return JSON.parse(trimmed);
  } catch (directError) {
    logJsonParseError('JSON.parse direct', directError, trimmed);

    const fenced = trimmed.match(/```(?:json)?\s*([\s\S]*?)```/i);
    if (fenced?.[1]) {
      try {
        return JSON.parse(fenced[1].trim());
      } catch (fencedError) {
        logJsonParseError('JSON.parse fenced', fencedError, fenced[1].trim());
      }
    }

    const start = trimmed.indexOf('{');
    const end = trimmed.lastIndexOf('}');
    if (start >= 0 && end > start) {
      const slice = trimmed.slice(start, end + 1);
      try {
        return JSON.parse(slice);
      } catch (sliceError) {
        logJsonParseError('JSON.parse object slice', sliceError, slice);
      }
    }

    throw new Error('Gemini response was not valid JSON');
  }
}

export const geminiResponseSchema = z.object({
  candidates: z
    .array(
      z.object({
        content: z.object({
          parts: z.array(
            z.object({
              text: z.string().optional(),
            }),
          ),
        }),
      }),
    )
    .min(1),
});
