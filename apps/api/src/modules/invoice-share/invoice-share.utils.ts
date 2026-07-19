import { randomBytes } from 'node:crypto';
import { z } from 'zod';
import { isValidIndianMobile } from '../../shared/utils/phone-number';

export const invoiceIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const partyIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const invoiceShareTokenParamSchema = z.object({
  token: z.string().min(16).max(128),
});

const optionalIndianPhone = z
  .string()
  .trim()
  .min(8)
  .max(20)
  .refine(isValidIndianMobile, {
    message: 'Phone must be a valid Indian mobile number',
  })
  .optional();

export const sendSaleInvoiceBodySchema = z.object({
  phone: optionalIndianPhone,
});

export const sendPaymentReminderBodySchema = z.object({
  /** Optional — ignored for amount; reminders always use party outstanding. */
  sales_document_id: z.string().uuid().optional(),
  phone: optionalIndianPhone,
  due_date: z.string().min(1).optional(),
});

export type SendSaleInvoiceBody = z.infer<typeof sendSaleInvoiceBodySchema>;
export type SendPaymentReminderBody = z.infer<
  typeof sendPaymentReminderBodySchema
>;

/** 32 bytes → 43-char base64url; not guessable / enumerable. */
export function generateInvoiceShareToken(): string {
  return randomBytes(32).toString('base64url');
}

export function buildInvoiceShareUrl(
  websiteUrl: string,
  token: string,
): string {
  const base = websiteUrl.replace(/\/$/, '');
  return `${base}/invoice/${token}`;
}

export function formatDisplayDate(value: Date | string): string {
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) {
    return String(value);
  }
  return date.toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

export function paymentStatusFromAmounts(
  totalAmount: string,
  paidAmount: string,
): 'unpaid' | 'partial' | 'paid' {
  const total = Number.parseFloat(totalAmount) || 0;
  const paid = Number.parseFloat(paidAmount) || 0;
  if (paid <= 0) return 'unpaid';
  if (paid + 0.0001 >= total) return 'paid';
  return 'partial';
}

export function dueAmount(totalAmount: string, paidAmount: string): string {
  const due =
    (Number.parseFloat(totalAmount) || 0) -
    (Number.parseFloat(paidAmount) || 0);
  return Math.max(0, due).toFixed(4);
}
