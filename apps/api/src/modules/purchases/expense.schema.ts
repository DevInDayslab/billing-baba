import { z } from 'zod';

const sortFieldValues = ['expense_date', 'created_at', 'amount'] as const;
const sortOrderValues = ['asc', 'desc'] as const;
const paymentModeValues = [
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
] as const;

export const listExpensesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  category_id: z.uuid().optional(),
  party_id: z.uuid().optional(),
  from: z.string().date().optional(),
  to: z.string().date().optional(),
  min_amount: z.string().optional(),
  max_amount: z.string().optional(),
  payment_mode: z.enum(paymentModeValues).optional(),
  sort: z.enum(sortFieldValues).default('expense_date'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListExpensesQuery = z.infer<typeof listExpensesQuerySchema>;

export const createExpenseBodySchema = z.object({
  category_id: z.uuid('Invalid category ID'),
  expense_item_id: z.uuid('Invalid expense item ID').optional().nullable(),
  party_id: z.uuid('Invalid party ID').optional().nullable(),
  amount: z.string().regex(/^\d+(\.\d{1,4})?$/, 'Invalid amount'),
  tax_amount: z
    .string()
    .regex(/^\d+(\.\d{1,4})?$/, 'Invalid tax amount')
    .optional(),
  tax_rate: z
    .string()
    .regex(/^\d+(\.\d{1,4})?$/, 'Invalid tax rate')
    .optional(),
  description: z.string().trim().max(2000).optional().nullable(),
  notes: z.string().trim().max(2000).optional().nullable(),
  reference_number: z.string().trim().max(100).optional().nullable(),
  attachments: z.array(z.string().url()).optional(),
  expense_date: z.string().date('Invalid expense date'),
  payment_mode: z.enum(paymentModeValues).optional().nullable(),
});

export type CreateExpenseBody = z.infer<typeof createExpenseBodySchema>;

export const updateExpenseBodySchema = createExpenseBodySchema
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateExpenseBody = z.infer<typeof updateExpenseBodySchema>;

export const expenseIdParamSchema = z.object({
  id: z.uuid('Invalid expense ID'),
});
