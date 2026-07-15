import type { PartyType } from './loyalty.types';

/** Default earn rule: 1 point per ₹100 spent when no loyalty_rules row exists. */
export const DEFAULT_RUPEES_PER_POINT = 100;

/** 1 loyalty point redeems for ₹1 (matches client placeholder). */
export const RUPEES_PER_REDEEMED_POINT = 1;

export const LOYALTY_EARN_DOCUMENT_TYPES = [
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
] as const;

export type LoyaltyEarnDocumentType =
  (typeof LOYALTY_EARN_DOCUMENT_TYPES)[number];

export function isEligiblePartyType(partyType: PartyType): boolean {
  return partyType === 'customer' || partyType === 'both';
}

export function isLoyaltyEarnDocumentType(
  documentType: string,
): documentType is LoyaltyEarnDocumentType {
  return (LOYALTY_EARN_DOCUMENT_TYPES as readonly string[]).includes(
    documentType,
  );
}

export function pointsEarnedForSpend(
  spendAmount: number,
  rupeesPerPoint: number,
): number {
  if (spendAmount <= 0 || rupeesPerPoint <= 0) {
    return 0;
  }
  return Math.floor(spendAmount / rupeesPerPoint);
}

export function formatLoyaltyPoints(value: number): string {
  return value.toFixed(4);
}

export function parseLoyaltyPoints(value: string | number | undefined): number {
  if (value === undefined || value === '') {
    return 0;
  }
  const parsed = Number(String(value).trim());
  return Number.isFinite(parsed) ? parsed : 0;
}
