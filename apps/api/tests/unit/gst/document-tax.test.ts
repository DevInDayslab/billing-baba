import { describe, expect, test } from 'bun:test';
import {
  calculateLineTax,
  resolveTaxType,
  sumDocumentTotals,
} from '../../../src/shared/documents/document-tax.service';

describe('document-tax.service', () => {
  test('calculates CGST/SGST split for intra-state GST', () => {
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

  test('calculates tax-inclusive line total', () => {
    const result = calculateLineTax({
      quantity: '1',
      unitPrice: '118',
      discountAmount: '0',
      taxType: 'cgst_sgst',
      taxRate: '18',
      taxInclusive: true,
    });

    expect(result.lineTotal).toBe('118');
    expect(Number.parseFloat(result.cgstAmount)).toBeGreaterThan(0);
  });

  test('resolves IGST for inter-state GST', () => {
    expect(resolveTaxType(true, '27', '09')).toBe('igst');
    expect(resolveTaxType(true, '27', '27')).toBe('cgst_sgst');
    expect(resolveTaxType(false, '27', '09')).toBe('none');
  });

  test('sums document totals from lines', () => {
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
