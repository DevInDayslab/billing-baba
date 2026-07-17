import { z } from 'zod';

const leadSourceValues = [
  'google_ads',
  'referral',
  'website',
  'walk_in',
  'other',
] as const;

const leadStatusValues = [
  'new',
  'contacted',
  'qualified',
  'converted',
  'lost',
] as const;

const leadActivityTypeValues = [
  'call',
  'email',
  'meeting',
  'note',
  'status_change',
] as const;

const optionalEmail = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value))
  .pipe(z.union([z.undefined(), z.email('Invalid email address')]));

const optionalText = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value));

export const listLeadsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: optionalText,
  status: z.enum(leadStatusValues).optional(),
  lead_source: z.enum(leadSourceValues).optional(),
  from: z.string().datetime({ offset: true }).optional(),
  to: z.string().datetime({ offset: true }).optional(),
});

export type ListLeadsQuery = z.infer<typeof listLeadsQuerySchema>;

export const createLeadBodySchema = z.object({
  id: z.uuid('Invalid lead ID').optional(),
  name: z.string().trim().min(1, 'Lead name is required').max(200),
  phone: z.string().trim().min(1, 'Phone is required').max(20),
  email: optionalEmail,
  company: optionalText,
  lead_source: z.enum(leadSourceValues).optional(),
  status: z.enum(leadStatusValues).optional().default('new'),
  assigned_to: optionalText,
  notes: z
    .string()
    .trim()
    .max(2000)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
});

export type CreateLeadBody = z.infer<typeof createLeadBodySchema>;

export const updateLeadBodySchema = createLeadBodySchema
  .omit({ id: true })
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateLeadBody = z.infer<typeof updateLeadBodySchema>;

export const leadIdParamSchema = z.object({
  id: z.uuid('Invalid lead ID'),
});

export type LeadIdParam = z.infer<typeof leadIdParamSchema>;

export const createLeadActivityBodySchema = z.object({
  type: z.enum(leadActivityTypeValues),
  notes: z
    .string()
    .trim()
    .max(2000)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  added_by: optionalText,
});

export type CreateLeadActivityBody = z.infer<
  typeof createLeadActivityBodySchema
>;
