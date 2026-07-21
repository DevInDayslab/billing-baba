import { describe, expect, test } from 'bun:test';
import { PaymentQrService } from '../../../src/modules/invoice-artifacts/payment-qr.service';

describe('PaymentQrService', () => {
  const service = new PaymentQrService();

  test('builds UPI payload with due amount and mam=0.01', () => {
    const payload = service.buildUpiPayload({
      upiId: 'shop@okaxis',
      companyName: 'Acme Stores',
      dueAmount: '250.50',
      invoiceNumber: 'INV-42',
    });

    expect(payload).toContain('upi://pay?');
    expect(payload).toContain('pa=shop%40okaxis');
    expect(payload).toContain('am=250.50');
    expect(payload).toContain('mam=0.01');
    expect(payload).toContain('tn=Invoice_INV-42');
    expect(payload).toContain('cu=INR');
  });

  test('returns null when UPI ID is missing', () => {
    expect(
      service.buildUpiPayload({
        upiId: '  ',
        companyName: 'Acme',
        dueAmount: '10',
        invoiceNumber: '1',
      }),
    ).toBeNull();
  });

  test('returns null when due amount is zero', () => {
    expect(
      service.buildUpiPayload({
        upiId: 'shop@upi',
        companyName: 'Acme',
        dueAmount: '0',
        invoiceNumber: '1',
      }),
    ).toBeNull();
  });

  test('generate returns PNG buffer and data URL', async () => {
    const result = await service.generate({
      upiId: 'shop@upi',
      companyName: 'Acme',
      dueAmount: '99.00',
      invoiceNumber: 'INV-1',
    });

    expect(result).not.toBeNull();
    expect(result!.buffer.length).toBeGreaterThan(100);
    expect(result!.dataUrl.startsWith('data:image/png')).toBe(true);
    expect(result!.amount).toBe('99.00');
    expect(result!.upiId).toBe('shop@upi');
  });
});
