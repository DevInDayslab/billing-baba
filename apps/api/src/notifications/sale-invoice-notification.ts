import { SALE_INVOICE_TEMPLATE } from './templates';
import {
  formatInrAmount,
  type NotificationContent,
  renderTemplate,
} from './types';

export type SaleInvoiceNotificationInput = {
  customerName: string;
  invoiceNumber: string;
  amount: string | number;
  invoiceUrl: string;
  companyName?: string;
  invoiceId?: string | null;
  /** HTTPS URL resolved via StorageService for WhatsApp media attachment. */
  mediaUrl?: string | null;
};

export function buildSaleInvoiceNotification(
  input: SaleInvoiceNotificationInput,
): NotificationContent {
  const amount = formatInrAmount(input.amount);
  const body = renderTemplate(SALE_INVOICE_TEMPLATE, {
    customer_name: input.customerName,
    invoice_number: input.invoiceNumber,
    amount,
    invoice_url: input.invoiceUrl,
  });

  return {
    type: 'sale_invoice',
    title: 'Sale invoice',
    body,
    metadata: {
      customerName: input.customerName,
      invoiceNumber: input.invoiceNumber,
      amount,
      companyName: input.companyName ?? null,
      invoiceId: input.invoiceId ?? null,
    },
    deepLinks: {
      primary: input.invoiceUrl,
      invoice: input.invoiceUrl,
    },
  };
}
