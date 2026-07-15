import { z } from 'zod';

const moneyString = z
  .string()
  .trim()
  .regex(/^\d+(\.\d{1,4})?$/, 'Invalid money value');

const sortOrderValues = ['asc', 'desc'] as const;

export const partyLoyaltyParamSchema = z.object({
  id: z.uuid('Invalid party ID'),
});

export const listLoyaltyTransactionsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  from: z.iso.datetime().optional(),
  to: z.iso.datetime().optional(),
  sort: z.enum(['created_at'] as const).default('created_at'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListLoyaltyTransactionsQuery = z.infer<
  typeof listLoyaltyTransactionsQuerySchema
>;

export const updateLoyaltyRulesBodySchema = z
  .object({
    rupees_per_point: moneyString
      .refine((value) => parseFloat(value) > 0, 'Must be greater than 0')
      .optional(),
    is_active: z.boolean().optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateLoyaltyRulesBody = z.infer<
  typeof updateLoyaltyRulesBodySchema
>;
