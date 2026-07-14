import { describe, expect, it } from 'bun:test';
import {
  DEFAULT_RUPEES_PER_POINT,
  isEligiblePartyType,
  isLoyaltyEarnDocumentType,
  pointsEarnedForSpend,
} from '../src/modules/loyalty/loyalty.utils';

describe('loyalty.utils', () => {
  it('awards 1 point per ₹100 spent using floor', () => {
    expect(pointsEarnedForSpend(0, DEFAULT_RUPEES_PER_POINT)).toBe(0);
    expect(pointsEarnedForSpend(99, DEFAULT_RUPEES_PER_POINT)).toBe(0);
    expect(pointsEarnedForSpend(100, DEFAULT_RUPEES_PER_POINT)).toBe(1);
    expect(pointsEarnedForSpend(250, DEFAULT_RUPEES_PER_POINT)).toBe(2);
    expect(pointsEarnedForSpend(999, DEFAULT_RUPEES_PER_POINT)).toBe(9);
  });

  it('respects custom rupees-per-point rules', () => {
    expect(pointsEarnedForSpend(500, 50)).toBe(10);
    expect(pointsEarnedForSpend(499, 50)).toBe(9);
  });

  it('identifies eligible customer party types', () => {
    expect(isEligiblePartyType('customer')).toBe(true);
    expect(isEligiblePartyType('both')).toBe(true);
    expect(isEligiblePartyType('supplier')).toBe(false);
  });

  it('limits loyalty earning to finalized sale document types', () => {
    expect(isLoyaltyEarnDocumentType('tax_invoice')).toBe(true);
    expect(isLoyaltyEarnDocumentType('pos')).toBe(true);
    expect(isLoyaltyEarnDocumentType('estimate')).toBe(false);
    expect(isLoyaltyEarnDocumentType('sales_return')).toBe(false);
  });
});
