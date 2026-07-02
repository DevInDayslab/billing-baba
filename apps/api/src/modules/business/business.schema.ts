import { z } from 'zod';

export const createBusinessBodySchema = z.object({
  name: z.string().trim().min(1, 'Business name is required').max(200),
  owner_name: z.string().trim().max(200).optional(),
  phone: z.string().trim().max(20).optional(),
  email: z
    .email()
    .trim()
    .max(200)
    .optional()
    .transform((value) => (value === '' ? undefined : value))
    .pipe(z.string().optional()),
  gstin: z.string().trim().max(15).optional(),
  business_type: z.string().trim().max(100).optional(),
  state: z.string().trim().max(100).optional(),
  state_code: z.string().trim().max(4).optional(),
  currency: z.string().trim().max(10).optional(),
  address: z.string().trim().max(500).optional(),
});

export type CreateBusinessBody = z.infer<typeof createBusinessBodySchema>;
