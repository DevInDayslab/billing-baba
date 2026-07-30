import {
  normalizeMoney,
  parseMoney,
} from '../../modules/inventory/inventory.utils';
import type { TaxType } from './document.types';

export type LineTaxInput = {
  quantity: string;
  unitPrice: string;
  discountAmount: string;
  taxType: TaxType;
  taxRate: string;
  taxInclusive?: boolean;
};

export type LineTaxResult = {
  taxableAmount: string;
  cgstAmount: string;
  sgstAmount: string;
  igstAmount: string;
  taxAmount: string;
  lineTotal: string;
};

export function calculateLineTax(input: LineTaxInput): LineTaxResult {
  const qty = parseMoney(input.quantity);
  const unitPrice = parseMoney(input.unitPrice);
  const discount = parseMoney(input.discountAmount ?? '0');
  const rate = parseMoney(input.taxRate ?? '0');

  const gross = qty * unitPrice;
  let taxable: number;

  if (input.taxInclusive && rate > 0) {
    const inclusiveTotal = gross;
    taxable = Math.max(0, inclusiveTotal / (1 + rate / 100) - discount);
  } else {
    taxable = Math.max(0, gross - discount);
  }

  let cgst = 0;
  let sgst = 0;
  let igst = 0;

  if (input.taxType === 'cgst_sgst' && rate > 0) {
    const halfRate = rate / 2;
    cgst = (taxable * halfRate) / 100;
    sgst = (taxable * halfRate) / 100;
  } else if (input.taxType === 'igst' && rate > 0) {
    igst = (taxable * rate) / 100;
  }

  const taxAmount = cgst + sgst + igst;
  const lineTotal =
    input.taxInclusive && rate > 0 ? gross - discount : taxable + taxAmount;

  return {
    taxableAmount: normalizeMoney(taxable),
    cgstAmount: normalizeMoney(cgst),
    sgstAmount: normalizeMoney(sgst),
    igstAmount: normalizeMoney(igst),
    taxAmount: normalizeMoney(taxAmount),
    lineTotal: normalizeMoney(lineTotal),
  };
}

export function resolveTaxType(
  isGstFormal: boolean,
  businessStateCode: string | null,
  partyStateCode: string | null,
): TaxType {
  if (!isGstFormal) {
    return 'none';
  }

  if (!businessStateCode || !partyStateCode) {
    return 'cgst_sgst';
  }

  return businessStateCode === partyStateCode ? 'cgst_sgst' : 'igst';
}

export function sumDocumentTotals(
  lines: Array<{
    discountAmount: string;
    cgstAmount: string;
    sgstAmount: string;
    igstAmount: string;
    lineTotal: string;
    quantity: string;
    unitPrice: string;
  }>,
): {
  subtotal: string;
  discountTotal: string;
  taxAmount: string;
  totalAmount: string;
} {
  let subtotal = 0;
  let discountTotal = 0;
  let taxAmount = 0;
  let totalAmount = 0;

  for (const line of lines) {
    const gross = parseMoney(line.quantity) * parseMoney(line.unitPrice);
    subtotal += gross;
    discountTotal += parseMoney(line.discountAmount);
    taxAmount +=
      parseMoney(line.cgstAmount) +
      parseMoney(line.sgstAmount) +
      parseMoney(line.igstAmount);
    totalAmount += parseMoney(line.lineTotal);
  }

  return {
    subtotal: normalizeMoney(subtotal),
    discountTotal: normalizeMoney(discountTotal),
    taxAmount: normalizeMoney(taxAmount),
    totalAmount: normalizeMoney(totalAmount),
  };
}
