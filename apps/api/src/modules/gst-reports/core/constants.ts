/** B2C large inter-state threshold: Rs 2,50,000 (invoice value). */
export const B2CL_THRESHOLD_PAISE = BigInt(25_000_000);

export const GST_OUTWARD_SALE_TYPES = [
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
] as const;

export const GST_CREDIT_NOTE_TYPE = 'sales_return' as const;

export const GST_PURCHASE_BILL_TYPE = 'purchase_bill' as const;

export const GST_DEBIT_NOTE_TYPE = 'purchase_return' as const;

export const GST_EXCLUDED_SALE_TYPES = [
  'estimate',
  'sale_order',
  'delivery_challan',
] as const;

export const GST_INCLUDED_SALE_TYPES = [
  ...GST_OUTWARD_SALE_TYPES,
  GST_CREDIT_NOTE_TYPE,
] as const;

export const GST_INCLUDED_PURCHASE_TYPES = [
  GST_PURCHASE_BILL_TYPE,
  GST_DEBIT_NOTE_TYPE,
] as const;

export const EXPORT_SUPPLY_TYPES = new Set([
  'export_with_payment',
  'export_without_payment',
  'sez_with_payment',
  'sez_without_payment',
]);

export const FINANCIAL_YEAR_START_MONTH = 4; // April (1-based)
