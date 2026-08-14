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
  business_category: z.string().trim().max(100).optional(),
  state: z.string().trim().max(100).optional(),
  state_code: z.string().trim().max(4).optional(),
  currency: z.string().trim().max(10).optional(),
  address: z.string().trim().max(500).optional(),
});

export type CreateBusinessBody = z.infer<typeof createBusinessBodySchema>;

const optionalEmail = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value))
  .pipe(z.union([z.undefined(), z.email('Invalid email address')]));

const optionalPhone = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value))
  .pipe(
    z.union([
      z.undefined(),
      z.string().regex(/^\d{10}$/, 'Phone must be exactly 10 digits'),
    ]),
  );

const optionalPincode = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value))
  .pipe(
    z.union([
      z.undefined(),
      z.string().regex(/^\d{6}$/, 'Pincode must be exactly 6 digits'),
    ]),
  );

export const updateBusinessProfileBodySchema = z.object({
  name: z.string().trim().min(1, 'Business name is required').max(200),
  phone: optionalPhone,
  email: optionalEmail,
  gstin: z
    .string()
    .trim()
    .max(15, 'GSTIN must be at most 15 characters')
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  business_type: z
    .string()
    .trim()
    .max(100)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  business_category: z
    .string()
    .trim()
    .max(100)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  state: z
    .string()
    .trim()
    .max(100)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  pincode: optionalPincode,
  address: z
    .string()
    .trim()
    .max(500)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  upi_id: z
    .string()
    .trim()
    .max(100)
    .optional()
    .transform((value) => (value === '' ? undefined : value))
    .refine(
      (value) =>
        value === undefined || /^[\w.-]{2,60}@[\w.-]{2,40}$/.test(value),
      { message: 'UPI ID must look like name@bank' },
    ),
});

export type UpdateBusinessProfileBody = z.infer<
  typeof updateBusinessProfileBodySchema
>;
