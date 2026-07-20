import { describe, expect, test } from 'bun:test';
import { InvoicePreviewRenderer } from '../../../src/modules/invoice-artifacts/invoice-preview.renderer';

describe('InvoicePreviewRenderer', () => {
  const renderer = new InvoicePreviewRenderer();

  test('renders portrait PNG under max width with required fields', async () => {
    const buffer = await renderer.render({
      companyName: 'Acme Traders',
      companyAddress: '12 Market Road, Delhi',
      companyPhone: '9876543210',
      companyGstin: '07AAAAA0000A1Z5',
      logoBuffer: null,
      invoiceNumber: 'INV-100',
      invoiceDate: '20 Jul 2026',
      customerName: 'Rahul Sharma',
      customerPhone: '9123456789',
      lines: [
        {
          itemName: 'Notebook',
          quantity: '2',
          unit: 'pcs',
          unitPrice: '50',
          lineTotal: '100',
        },
        {
          itemName: 'Pen',
          quantity: '5',
          unit: 'pcs',
          unitPrice: '10',
          lineTotal: '50',
        },
      ],
      totalAmount: '150.00',
      paidAmount: '50.00',
      dueAmount: '100.00',
      loyalty: {
        earnedPoints: '1.0000',
        redeemedPoints: '0.0000',
        pointsAvailable: '10.0000',
      },
    });

    expect(buffer.length).toBeGreaterThan(1000);
    // PNG magic header
    expect(buffer[0]).toBe(0x89);
    expect(buffer[1]).toBe(0x50);
    expect(buffer[2]).toBe(0x4e);
    expect(buffer[3]).toBe(0x47);
  });

  test('caps long line lists without throwing', async () => {
    const lines = Array.from({ length: 20 }, (_, i) => ({
      itemName: `Item ${i + 1}`,
      quantity: '1',
      unit: 'pcs',
      unitPrice: '10',
      lineTotal: '10',
    }));

    const buffer = await renderer.render({
      companyName: 'Shop',
      companyAddress: null,
      companyPhone: null,
      companyGstin: null,
      logoBuffer: null,
      invoiceNumber: '1',
      invoiceDate: '20 Jul 2026',
      customerName: 'Customer',
      customerPhone: null,
      lines,
      totalAmount: '200',
      paidAmount: '0',
      dueAmount: '200',
      loyalty: null,
    });

    expect(buffer.length).toBeGreaterThan(500);
  });
});
