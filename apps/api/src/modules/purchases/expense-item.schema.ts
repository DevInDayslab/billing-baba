import { z } from 'zod';

const sortFieldValues = ['name', 'created_at', 'price'] as const;
const sortOrderValues = ['asc', 'desc'] as const;

const moneyPattern = /^\d+(\.\d{1,4})?$/;

export const listExpenseItemsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  sort: z.enum(sortFieldValues).default('name'),
  order: z.enum(sortOrderValues).default('asc'),
});

export type ListExpenseItemsQuery = z.infer<typeof listExpenseItemsQuerySchema>;

export const createExpenseItemBodySchema = z.object({
  name: z.string().trim().min(1, 'Item name is required').max(200),
  hsn_sac: z.string().trim().max(50).optional().nullable(),
  price: z
    .string()
    .regex(moneyPattern, 'Invalid price')
    .optional()
    .default('0'),
  price_is_tax_inclusive: z.boolean().optional().default(false),
  tax_rate: z
    .string()
    .regex(moneyPattern, 'Invalid tax rate')
    .optional()
    .default('0'),
});

export type CreateExpenseItemBody = z.infer<typeof createExpenseItemBodySchema>;

export const updateExpenseItemBodySchema = z
  .object({
    name: z.string().trim().min(1).max(200).optional(),
    hsn_sac: z.string().trim().max(50).optional().nullable(),
    price: z.string().regex(moneyPattern, 'Invalid price').optional(),
    price_is_tax_inclusive: z.boolean().optional(),
    tax_rate: z.string().regex(moneyPattern, 'Invalid tax rate').optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateExpenseItemBody = z.infer<typeof updateExpenseItemBodySchema>;

export const expenseItemIdParamSchema = z.object({
  id: z.uuid('Invalid expense item ID'),
});
