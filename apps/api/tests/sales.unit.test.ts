import { describe, expect, it } from 'bun:test';
import {
  calculateLineTax,
  resolveTaxType,
  sumDocumentTotals,
} from '../src/modules/sales/sales-tax.service';

describe('sales-tax.service', () => {
  it('calculates CGST/SGST split for intra-state GST', () => {
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
