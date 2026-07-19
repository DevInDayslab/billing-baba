import { describe, expect, test } from 'bun:test';
import {
  generateInvoiceShareToken,
  paymentStatusFromAmounts,
  dueAmount,
} from '../../../src/modules/invoice-share/invoice-share.utils';

describe('invoice share tokens', () => {
  test('generates high-entropy unique tokens', () => {
    const a = generateInvoiceShareToken();
    const b = generateInvoiceShareToken();
    expect(a.length).toBeGreaterThanOrEqual(40);
    expect(b.length).toBeGreaterThanOrEqual(40);
    expect(a).not.toBe(b);
    expect(a).not.toMatch(/[+/=]/);
  });

  test('payment status and due amount', () => {
    expect(paymentStatusFromAmounts('100', '0')).toBe('unpaid');
    expect(paymentStatusFromAmounts('100', '40')).toBe('partial');
    expect(paymentStatusFromAmounts('100', '100')).toBe('paid');
    expect(dueAmount('100', '40')).toBe('60.0000');
  });
});
