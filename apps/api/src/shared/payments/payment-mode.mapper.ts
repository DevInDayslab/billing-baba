import type { AppConfig } from '../../config/app_config';
import type { RazorpayPaymentResult } from './razorpay_types';

export type AccountingPaymentMode =
  | 'cash'
  | 'upi'
  | 'card'
  | 'cheque'
  | 'bank_transfer'
  | 'other';

/** Maps Razorpay method strings to accounting payment_mode values. */
export function mapRazorpayMethodToAccountingMode(
  method: string | null,
): AccountingPaymentMode {
  switch (method) {
    case 'upi':
      return 'upi';
    case 'card':
    case 'credit_card':
    case 'debit_card':
    case 'emi':
      return 'card';
    case 'netbanking':
      return 'bank_transfer';
    case 'wallet':
      return 'other';
    default:
      return 'other';
  }
}

export type PaymentValidationInput = {
  intent: {
    razorpayOrderId: string;
    amountPaise: number;
    currency: string;
  };
  razorpayPayment: RazorpayPaymentResult;
  merchantKeyId: string;
  config: AppConfig;
};

export type PaymentValidationResult =
  | { valid: true }
  | { valid: false; reason: string };

/** Validates a fetched Razorpay payment against a gateway intent. */
export class PaymentValidationService {
  validate(input: PaymentValidationInput): PaymentValidationResult {
    const { intent, razorpayPayment, merchantKeyId, config } = input;

    if (config.razorpayKeyId && merchantKeyId !== config.razorpayKeyId) {
      return { valid: false, reason: 'Merchant key mismatch' };
    }

    if (razorpayPayment.orderId !== intent.razorpayOrderId) {
      return { valid: false, reason: 'Order id mismatch' };
    }

    if (razorpayPayment.amount !== intent.amountPaise) {
      return { valid: false, reason: 'Amount mismatch' };
    }

    if (razorpayPayment.currency !== intent.currency) {
      return { valid: false, reason: 'Currency mismatch' };
    }

    if (razorpayPayment.status !== 'captured' || !razorpayPayment.captured) {
      return { valid: false, reason: 'Payment not captured' };
    }

    return { valid: true };
  }
}
