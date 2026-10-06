import { describe, expect, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import { PaymentValidationService } from '../../../src/shared/payments/payment-mode.mapper';

const config = {
  razorpayKeyId: 'rzp_test_key',
} as AppConfig;

describe('PaymentValidationService', () => {
  const validator = new PaymentValidationService();

  test('accepts valid captured payment', () => {
    const result = validator.validate({
      intent: {
        razorpayOrderId: 'order_1',
        amountPaise: 450000,
        currency: 'INR',
      },
      razorpayPayment: {
        id: 'pay_1',
        orderId: 'order_1',
        amount: 450000,
        currency: 'INR',
        status: 'captured',
        method: 'upi',
        captured: true,
      },
      merchantKeyId: 'rzp_test_key',
      config,
    });
    expect(result.valid).toBe(true);
  });

  test('rejects amount mismatch', () => {
    const result = validator.validate({
      intent: {
        razorpayOrderId: 'order_1',
        amountPaise: 450000,
        currency: 'INR',
      },
      razorpayPayment: {
        id: 'pay_1',
        orderId: 'order_1',
        amount: 100,
        currency: 'INR',
        status: 'captured',
        method: 'upi',
        captured: true,
      },
      merchantKeyId: 'rzp_test_key',
      config,
    });
    expect(result.valid).toBe(false);
    if (!result.valid) {
      expect(result.reason).toBe('Amount mismatch');
    }
  });
});
