import { PAYMENT_RECEIVED_TEMPLATE } from './templates';
import {
  formatInrAmount,
  type NotificationContent,
  renderTemplate,
} from './types';

export type PaymentReceivedNotificationInput = {
  customerName: string;
  companyName: string;
  amount: string | number;
  paymentId?: string | null;
};

/**
 * Builds a payment-received WhatsApp/text notification.
 * Not wired into the payment workflow yet — call NotificationService explicitly.
 */
export function buildPaymentReceivedNotification(
  input: PaymentReceivedNotificationInput,
): NotificationContent {
  const amount = formatInrAmount(input.amount);
  const body = renderTemplate(PAYMENT_RECEIVED_TEMPLATE, {
    customer_name: input.customerName,
    company_name: input.companyName,
    amount,
  });

  return {
    type: 'payment_received',
    title: 'Payment received',
    body,
    metadata: {
      customerName: input.customerName,
      companyName: input.companyName,
      amount,
      paymentId: input.paymentId ?? null,
    },
    deepLinks: {},
  };
}
