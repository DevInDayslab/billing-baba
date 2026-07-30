import { describe, expect, test } from 'bun:test';
import { renderInvoiceDocumentHtml } from '../../../src/modules/invoice-artifacts/invoice-document.pdf-renderer';

describe('renderInvoiceDocumentHtml', () => {
  test('includes rupee amounts and public-invoice structure', () => {
    const html = renderInvoiceDocumentHtml({
      companyName: 'Acme',
      companyAddress: 'Delhi',
      companyPhone: null,
      companyEmail: null,
      companyGstin: null,
      logoSrc: null,
      invoiceNumber: 'INV-1',
      invoiceDate: '21 Jul 2026',
      paymentStatus: 'unpaid',
      customerName: 'Cust',
      customerPhone: null,
      customerEmail: null,
      customerGstin: null,
      lines: [
        {
          itemName: 'Item',
          quantity: '1',
          unit: 'pcs',
          unitPrice: '58',
          lineTotal: '58',
          taxAmount: '0',
          discountAmount: '0',
        },
      ],
      subtotal: '58',
      discountTotal: '0',
      taxAmount: '0',
      totalAmount: '58',
      paidAmount: '0',
      dueAmount: '58',
      notes: null,
      loyalty: null,
      qrDataUrl: null,
      qrAmount: null,
      qrUpiId: null,
      qrMerchant: null,
    });

    expect(html).toContain('Tax Invoice');
    expect(html).toContain('Bill to');
    expect(html).toContain('Amount due');
    expect(html).toContain('Authorized Signatory');
    expect(html).toContain('Powered by Billing Baba');
    expect(html).toContain('class="money">₹');
    expect(html).toContain('₹58.00');
    expect(html).toContain('BB Noto Sans');
    expect(html).not.toContain('Line items');
  });
});
