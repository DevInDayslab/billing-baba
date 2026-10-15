import { z } from 'zod';

const sortFieldValues = ['income_date', 'created_at', 'amount'] as const;
const sortOrderValues = ['asc', 'desc'] as const;
const paymentModeValues = [
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
] as const;

const moneyPattern = /^\d+(\.\d{1,4})?$/;

export const listOtherIncomesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  category_id: z.uuid().optional(),
  income_item_id: z.uuid().optional(),
  from: z.string().date().optional(),
  to: z.string().date().optional(),
  min_amount: z.string().optional(),
  max_amount: z.string().optional(),
  payment_mode: z.enum(paymentModeValues).optional(),
  sort: z.enum(sortFieldValues).default('income_date'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListOtherIncomesQuery = z.infer<typeof listOtherIncomesQuerySchema>;

export const createOtherIncomeBodySchema = z.object({
  category_id: z.uuid('Invalid category ID'),
  income_item_id: z.uuid('Invalid income item ID').optional().nullable(),
  amount: z.string().regex(moneyPattern, 'Invalid amount'),
  quantity: z.string().regex(moneyPattern, 'Invalid quantity').optional().nullable(),
  tax_amount: z
    .string()
    .regex(moneyPattern, 'Invalid tax amount')
    .optional(),
  tax_rate: z
    .string()
    .regex(moneyPattern, 'Invalid tax rate')
    .optional(),
  description: z.string().trim().max(2000).optional().nullable(),
  notes: z.string().trim().max(2000).optional().nullable(),
  reference_number: z.string().trim().max(100).optional().nullable(),
  income_date: z.string().date('Invalid income date'),
  payment_mode: z.enum(paymentModeValues).optional().nullable(),
  bank_account_id: z.string().uuid().optional().nullable(),
});

export type CreateOtherIncomeBody = z.infer<typeof createOtherIncomeBodySchema>;

export const updateOtherIncomeBodySchema = createOtherIncomeBodySchema
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateOtherIncomeBody = z.infer<typeof updateOtherIncomeBodySchema>;

export const otherIncomeIdParamSchema = z.object({
  id: z.uuid('Invalid other income ID'),
});
