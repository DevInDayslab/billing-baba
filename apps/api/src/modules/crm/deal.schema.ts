import { z } from 'zod';

const dealStageValues = [
  'qualification',
  'needs_analysis',
  'value_proposition',
  'identify_decision_makers',
  'proposal_price_quote',
  'negotiation_review',
  'closed_won',
  'closed_lost',
  'closed_lost_to_competition',
] as const;

const optionalText = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value));

export const listDealsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: optionalText,
  account_name: optionalText,
  assigned_to: optionalText,
  stage: z.enum(dealStageValues).optional(),
  from: z.string().datetime({ offset: true }).optional(),
  to: z.string().datetime({ offset: true }).optional(),
});

export type ListDealsQuery = z.infer<typeof listDealsQuerySchema>;

export const createDealBodySchema = z.object({
  id: z.uuid('Invalid deal ID').optional(),
  name: z.string().trim().min(1, 'Deal name is required').max(200),
  stage: z.enum(dealStageValues).optional(),
  account_name: optionalText,
  assigned_to: optionalText,
  amount: z.coerce.number().min(0).optional(),
  expected_close_date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format')
    .optional(),
  description: z
    .string()
    .trim()
    .max(2000)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
});

export type CreateDealBody = z.infer<typeof createDealBodySchema>;

export const updateDealBodySchema = createDealBodySchema
  .omit({ id: true })
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateDealBody = z.infer<typeof updateDealBodySchema>;

export const dealIdParamSchema = z.object({
  id: z.uuid('Invalid deal ID'),
});

export type DealIdParam = z.infer<typeof dealIdParamSchema>;
