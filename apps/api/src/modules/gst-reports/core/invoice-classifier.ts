import { isValid as isValidGstin } from '../../../shared/utils/gstin-validator';
import {
  B2CL_THRESHOLD_PAISE,
  EXPORT_SUPPLY_TYPES,
} from './constants';
import { isInterStateSupply } from './place-of-supply';
import { parseMoneyToPaise } from './gst-money';
import type { GstBusinessContext, GstSalesDocumentModel } from './models';

export type OutwardSaleClass =
  | 'b2b'
  | 'b2cl'
  | 'b2cs'
  | 'export'
  | 'nil_exempt'
  | 'credit_registered'
  | 'credit_unregistered';

export function isRegisteredParty(gstin: string | null | undefined): boolean {
  if (!gstin?.trim()) return false;
  return isValidGstin(gstin);
}

export function isExportSupply(supplyType: string): boolean {
  return EXPORT_SUPPLY_TYPES.has(supplyType);
}

export function isNilOrExemptDocument(doc: GstSalesDocumentModel): boolean {
  if (doc.documentType === 'bill_of_supply') return true;
  return doc.lines.every(
    (line) =>
      line.taxType === 'none' ||
      line.taxType === 'exempt' ||
      parseMoneyToPaise(line.cgstAmount) +
        parseMoneyToPaise(line.sgstAmount) +
        parseMoneyToPaise(line.igstAmount) ===
        BigInt(0),
  );
}

export function classifyOutwardSale(
  business: GstBusinessContext,
  doc: GstSalesDocumentModel,
): OutwardSaleClass {
  if (doc.isCreditNote) {
    const partyGstin = doc.party.gstin;
    return isRegisteredParty(partyGstin)
      ? 'credit_registered'
      : 'credit_unregistered';
  }

  if (isExportSupply(doc.supplyType)) {
    return 'export';
  }

  if (isNilOrExemptDocument(doc)) {
    return 'nil_exempt';
  }

  const registered = isRegisteredParty(doc.party.gstin);
  if (registered) return 'b2b';

  const hasIgst = doc.lines.some(
    (l) => parseMoneyToPaise(l.igstAmount) > BigInt(0),
  );
  const interState = isInterStateSupply(
    business,
    doc.partyStateCode,
    hasIgst,
  );
  const invoicePaise = parseMoneyToPaise(doc.totalAmount);

  if (interState && invoicePaise > B2CL_THRESHOLD_PAISE) {
    return 'b2cl';
  }

  return 'b2cs';
}
