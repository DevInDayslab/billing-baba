import { describe, expect, test } from 'bun:test';
import { B2CL_THRESHOLD_PAISE } from '../../../src/modules/gst-reports/core/constants';
import { classifyOutwardSale } from '../../../src/modules/gst-reports/core/invoice-classifier';
import type {
  GstBusinessContext,
  GstSalesDocumentModel,
} from '../../../src/modules/gst-reports/core/models';

const business: GstBusinessContext = {
  id: 'b1',
  gstin: '27AAAAA0000A1Z5',
  stateCode: '27',
};

function baseDoc(overrides: Partial<GstSalesDocumentModel>): GstSalesDocumentModel {
  return {
    id: 'd1',
    documentType: 'tax_invoice',
    status: 'finalized',
    documentNumber: 'INV-1',
    documentSeries: 'INV',
    documentDate: new Date('2025-04-01'),
    party: { id: 'p1', name: 'Walk-in', gstin: null, stateCode: '09' },
    partyStateCode: '09',
    supplyType: 'domestic',
    subtotal: '100',
    totalAmount: '250000',
    originalDocumentId: null,
    originalDocumentNumber: null,
    originalDocumentDate: null,
    convertedFromId: null,
    lines: [
      {
        id: 'l1',
        itemId: 'i1',
        quantity: '1',
        unit: 'piece',
        unitPrice: '100',
        discountAmount: '0',
        taxType: 'igst',
        taxRate: '18',
        cgstAmount: '0',
        sgstAmount: '0',
        igstAmount: '18',
        cessRate: '0',
        cessAmount: '0',
        lineTotal: '118',
        item: {
          id: 'i1',
          name: 'Item',
          itemType: 'product',
          hsnCode: '1001',
        },
      },
    ],
    isGstFormal: true,
    isCreditNote: false,
    ...overrides,
  };
}

describe('invoice-classifier', () => {
  test('classifies B2CL above threshold inter-state', () => {
    const doc = baseDoc({
      totalAmount: String(Number(B2CL_THRESHOLD_PAISE) / 100 + 1),
    });
    expect(classifyOutwardSale(business, doc)).toBe('b2cl');
  });

  test('classifies B2CS at threshold', () => {
    const doc = baseDoc({ totalAmount: '250000' });
    expect(classifyOutwardSale(business, doc)).toBe('b2cs');
  });
});
