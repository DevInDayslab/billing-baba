import { PAYMENT_REMINDER_TEMPLATE } from './templates';
import {
  formatInrAmount,
  type NotificationContent,
  renderTemplate,
} from './types';

export type PaymentReminderNotificationInput = {
  customerName: string;
  companyName: string;
  amount: string | number;
  dueDate: string;
  invoiceUrl: string;
  invoiceNumber?: string | null;
  invoiceId?: string | null;
};

export function buildPaymentReminderNotification(
  input: PaymentReminderNotificationInput,
): NotificationContent {
  const amount = formatInrAmount(input.amount);
  const body = renderTemplate(PAYMENT_REMINDER_TEMPLATE, {
    customer_name: input.customerName,
    company_name: input.companyName,
    amount,
    due_date: input.dueDate,
    invoice_url: input.invoiceUrl,
  });

  return {
    type: 'payment_reminder',
    title: 'Payment reminder',
    body,
    metadata: {
      customerName: input.customerName,
      companyName: input.companyName,
      amount,
      dueDate: input.dueDate,
      invoiceNumber: input.invoiceNumber ?? null,
      invoiceId: input.invoiceId ?? null,
    },
    deepLinks: {
      primary: input.invoiceUrl,
      invoice: input.invoiceUrl,
    },
  };
}
