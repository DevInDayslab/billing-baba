import { z } from 'zod';

const contactActivityTypeValues = [
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

export const listContactsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: optionalText,
  account_name: optionalText,
  assigned_to: optionalText,
  from: z.string().datetime({ offset: true }).optional(),
  to: z.string().datetime({ offset: true }).optional(),
});

export type ListContactsQuery = z.infer<typeof listContactsQuerySchema>;

export const createContactBodySchema = z.object({
  id: z.uuid('Invalid contact ID').optional(),
  name: z.string().trim().min(1, 'Contact name is required').max(200),
  phone: z.string().trim().min(1, 'Phone is required').max(20),
  email: optionalEmail,
  first_name: optionalText,
  last_name: optionalText,
  salutation: optionalText,
  account_name: optionalText,
  assigned_to: optionalText,
  title: optionalText,
  description: z
    .string()
    .trim()
    .max(2000)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
});

export type CreateContactBody = z.infer<typeof createContactBodySchema>;

export const updateContactBodySchema = createContactBodySchema
  .omit({ id: true })
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateContactBody = z.infer<typeof updateContactBodySchema>;

export const contactIdParamSchema = z.object({
  id: z.uuid('Invalid contact ID'),
});

export type ContactIdParam = z.infer<typeof contactIdParamSchema>;

export const createContactActivityBodySchema = z.object({
  type: z.enum(contactActivityTypeValues),
  notes: z
    .string()
    .trim()
    .max(2000)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  added_by: optionalText,
});

export type CreateContactActivityBody = z.infer<
  typeof createContactActivityBodySchema
>;
