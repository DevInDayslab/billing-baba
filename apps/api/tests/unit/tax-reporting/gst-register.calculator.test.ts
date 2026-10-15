import { describe, expect, test } from 'bun:test';
import type { GstDataset } from '../../../src/modules/gst-reports/core/models';
import { buildGstRateSummary } from '../../../src/modules/tax-reporting/calculators/gst-rate-summary.calculator';
import { filterRegisterDocs } from '../../../src/modules/tax-reporting/calculators/gst-register-filters';
import { buildGstTransactionRegister } from '../../../src/modules/tax-reporting/calculators/gst-transaction-register.calculator';

const baseLine = {
  id: 'l1',
  itemId: 'i1',
  quantity: '1',
  unit: 'PCS',
  unitPrice: '100',
  discountAmount: '0',
  taxType: 'cgst_sgst',
  taxRate: '18',
  cgstAmount: '9',
  sgstAmount: '9',
  igstAmount: '0',
  cessRate: '0',
  cessAmount: '0',
  lineTotal: '118',
  item: {
    id: 'i1',
    name: 'Item',
    itemType: 'product' as const,
    hsnCode: '1234',
  },
};

function dataset(): GstDataset {
  return {
    business: { id: 'b1', gstin: '27AAAAA0000A1Z5', stateCode: '27' },
    cancelledBySeries: [],
    sales: [
      {
        id: 's1',
        documentType: 'tax_invoice',
        status: 'finalized',
        documentNumber: 'S-1',
        documentSeries: 'S',
        documentDate: new Date('2025-04-10T00:00:00.000Z'),
        party: {
          id: 'p1',
          name: 'Customer A',
          gstin: '27BBBBB1111B1Z5',
          stateCode: '27',
        },
        partyStateCode: '27',
        supplyType: 'domestic',
        subtotal: '100',
        totalAmount: '118',
        isGstFormal: true,
        originalDocumentId: null,
        originalDocumentNumber: null,
        originalDocumentDate: null,
        convertedFromId: null,
        lines: [baseLine],
        isCreditNote: false,
      },
      {
        id: 's2',
        documentType: 'sales_return',
        status: 'finalized',
        documentNumber: 'CN-1',
        documentSeries: 'CN',
        documentDate: new Date('2025-04-12T00:00:00.000Z'),
        party: {
          id: 'p1',
          name: 'Customer A',
          gstin: '27BBBBB1111B1Z5',
          stateCode: '27',
        },
        partyStateCode: '27',
        supplyType: 'domestic',
        subtotal: '50',
        totalAmount: '59',
        isGstFormal: true,
        originalDocumentId: null,
        originalDocumentNumber: null,
        originalDocumentDate: null,
        convertedFromId: null,
        lines: [
          {
            ...baseLine,
            id: 'l2',
            unitPrice: '50',
            cgstAmount: '4.5',
            sgstAmount: '4.5',
            lineTotal: '59',
          },
        ],
        isCreditNote: true,
      },
    ],
    purchases: [
      {
        id: 'pu1',
        documentType: 'purchase_bill',
        status: 'finalized',
        documentNumber: 'P-1',
        documentSeries: 'P',
        documentDate: new Date('2025-04-11T00:00:00.000Z'),
        party: {
          id: 'p2',
          name: 'Supplier B',
          gstin: '27CCCCC2222C1Z5',
          stateCode: '27',
        },
        partyStateCode: '27',
        totalAmount: '118',
        isGstFormal: true,
        originalDocumentId: null,
        originalDocumentNumber: null,
        originalDocumentDate: null,
        lines: [baseLine],
        isDebitNote: false,
      },
    ],
  };
}

describe('buildGstTransactionRegister', () => {
  test('nets credit notes in output tax summary', () => {
    const ds = dataset();
    const entries = filterRegisterDocs(ds, {
      page: 1,
      limit: 50,
      gst_formal: 'all',
      transaction_type: 'all',
    });
    const { summary } = buildGstTransactionRegister(entries, '27');
    expect(summary.output_total_tax).toBe('9.00');
    expect(summary.input_total_tax).toBe('18.00');
    expect(summary.net_tax_payable).toBe('-9.00');
  });
});

describe('buildGstRateSummary', () => {
  test('reconciles sale and purchase at same rate', () => {
    const ds = dataset();
    const entries = filterRegisterDocs(ds, {
      page: 1,
      limit: 50,
      gst_formal: 'all',
      transaction_type: 'all',
    });
    const { totals } = buildGstRateSummary(entries);
    expect(totals.sale_total_tax).toBe('9.00');
    expect(totals.purchase_total_tax).toBe('18.00');
  });
});
