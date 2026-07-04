import { describe, expect, it } from 'bun:test';
import { assertValidConversion } from '../src/modules/purchases/purchase-convert.rules';
import {
  calculateLineTax,
  resolveTaxType,
  sumDocumentTotals,
} from '../src/shared/documents/document-tax.service';

describe('document-tax.service (purchases)', () => {
  it('calculates CGST/SGST split for intra-state GST (exclusive)', () => {
    const result = calculateLineTax({
      quantity: '2',
      unitPrice: '100',
      discountAmount: '0',
      taxType: 'cgst_sgst',
      taxRate: '18',
    });

    expect(result.cgstAmount).toBe('18');
    expect(result.sgstAmount).toBe('18');
    expect(result.lineTotal).toBe('236');
  });

  it('calculates tax-inclusive line total', () => {
    const result = calculateLineTax({
      quantity: '1',
      unitPrice: '118',
      discountAmount: '0',
      taxType: 'cgst_sgst',
      taxRate: '18',
      taxInclusive: true,
    });

    expect(result.lineTotal).toBe('118');
    expect(parseFloat(result.cgstAmount)).toBeGreaterThan(0);
  });

  it('resolves IGST for inter-state GST', () => {
    const taxType = resolveTaxType(true, '27', '09');
    expect(taxType).toBe('igst');
  });

  it('sums document totals from lines', () => {
    const totals = sumDocumentTotals([
      {
        quantity: '1',
        unitPrice: '100',
        discountAmount: '0',
        cgstAmount: '9',
        sgstAmount: '9',
        igstAmount: '0',
        lineTotal: '118',
      },
    ]);

    expect(totals.totalAmount).toBe('118');
  });
});

describe('purchase-convert.rules', () => {
  it('allows purchase_order to purchase_bill', () => {
    expect(() =>
      assertValidConversion('purchase_order', 'purchase_bill'),
    ).not.toThrow();
  });

  it('rejects purchase_bill to purchase_bill', () => {
    expect(() =>
      assertValidConversion('purchase_bill', 'purchase_bill'),
    ).toThrow();
  });
});
