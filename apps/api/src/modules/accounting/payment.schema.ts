import { z } from 'zod';

const paymentModeValues = [
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
] as const;

const paymentDirectionValues = ['received', 'paid'] as const;

const shortPaymentHandlingValues = ['official_balance', 'unrecovered'] as const;

const moneyString = z
  .string()
  .trim()
  .regex(/^\d+(\.\d{1,4})?$/, 'Invalid money value');

export const listPaymentsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  party_id: z.uuid().optional(),
  direction: z.enum(paymentDirectionValues).optional(),
  from: z.iso.datetime().optional(),
  to: z.iso.datetime().optional(),
  sort: z.enum(['payment_date', 'created_at'] as const).default('payment_date'),
  order: z.enum(['asc', 'desc'] as const).default('desc'),
});

export type ListPaymentsQuery = z.infer<typeof listPaymentsQuerySchema>;

const allocationSchema = z.object({
  sales_document_id: z.uuid().optional(),
  purchase_document_id: z.uuid().optional(),
  allocated_amount: moneyString,
});

export const createPaymentBodySchema = z.object({
  party_id: z.uuid(),
  direction: z.enum(paymentDirectionValues),
  amount: moneyString,
  payment_mode: z.enum(paymentModeValues),
  payment_date: z.iso.datetime().optional(),
  reference_number: z.string().trim().max(100).optional().nullable(),
  notes: z.string().trim().max(2000).optional().nullable(),
  short_payment_handling: z.enum(shortPaymentHandlingValues).optional(),
  allocations: z.array(allocationSchema).optional().default([]),
});

export type CreatePaymentBody = z.infer<typeof createPaymentBodySchema>;

export const updatePaymentBodySchema = z
  .object({
    notes: z.string().trim().max(2000).nullable().optional(),
    reference_number: z.string().trim().max(100).nullable().optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdatePaymentBody = z.infer<typeof updatePaymentBodySchema>;

export const paymentIdParamSchema = z.object({
  id: z.uuid('Invalid payment ID'),
});

export const createAllocationBodySchema = z.object({
  sales_document_id: z.uuid().optional(),
  purchase_document_id: z.uuid().optional(),
  allocated_amount: moneyString,
});

export type CreateAllocationBody = z.infer<typeof createAllocationBodySchema>;

export const allocationIdParamSchema = z.object({
  id: z.uuid('Invalid payment ID'),
  allocationId: z.uuid('Invalid allocation ID'),
});
