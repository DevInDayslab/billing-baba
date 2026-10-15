import { z } from 'zod';

const sortFieldValues = ['name', 'created_at', 'price'] as const;
const sortOrderValues = ['asc', 'desc'] as const;

const moneyPattern = /^\d+(\.\d{1,4})?$/;

export const listIncomeItemsQuerySchema = z.object({
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

export type ListIncomeItemsQuery = z.infer<typeof listIncomeItemsQuerySchema>;

export const createIncomeItemBodySchema = z.object({
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

export type CreateIncomeItemBody = z.infer<typeof createIncomeItemBodySchema>;

export const updateIncomeItemBodySchema = z
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

export type UpdateIncomeItemBody = z.infer<typeof updateIncomeItemBodySchema>;

export const incomeItemIdParamSchema = z.object({
  id: z.uuid('Invalid income item ID'),
});
