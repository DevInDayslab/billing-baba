import { z } from 'zod';
import { PRICING_TIER_INPUT_VALUES } from '../../shared/pricing/pricing-tier';

const partyTypeValues = ['customer', 'supplier', 'both'] as const;
const partyCategoryValues = [
  'customer',
  'retailer',
  'wholesaler',
  'manufacturer',
  'custom',
] as const;
const pricingTierInput = z.enum(PRICING_TIER_INPUT_VALUES);
const sortFieldValues = ['name', 'created_at', 'opening_balance'] as const;
const sortOrderValues = ['asc', 'desc'] as const;

const optionalEmail = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value))
  .pipe(z.union([z.undefined(), z.email('Invalid email address')]));

const optionalMobile = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value));

const requiredMobile = z
  .string()
  .trim()
  .min(1, 'Mobile number is required')
  .transform((value) => value.replace(/\D/g, '').slice(-10))
  .refine((value) => value.length === 10, {
    message: 'Phone must be exactly 10 digits',
  });

const optionalText = (max: number) =>
  z
    .string()
    .trim()
    .max(max)
    .optional()
    .transform((value) => (value === '' ? undefined : value));

const additionalPhonesField = z
  .array(
    z
      .string()
      .trim()
      .min(1)
      .transform((value) => value.replace(/\D/g, '').slice(-10))
      .refine((value) => value.length === 10, {
        message: 'Each phone must be exactly 10 digits',
      }),
  )
  .optional()
  .default([]);

const optionalGstin = z
  .string()
  .trim()
  .optional()
  .transform((value) => (value === '' ? undefined : value))
  .pipe(
    z.union([
      z.undefined(),
      z
        .string()
        .max(15, 'GSTIN must be at most 15 characters')
        .regex(
          /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/,
          'Invalid GSTIN format',
        ),
    ]),
  );

const moneyField = z
  .union([z.string(), z.number()])
  .optional()
  .transform((value) => {
    if (value === undefined || value === '') return undefined;
    return String(value);
  })
  .pipe(
    z.union([
      z.undefined(),
      z.string().regex(/^-?\d+(\.\d{1,4})?$/, 'Must be a valid decimal amount'),
    ]),
  );

const optionalCurrency = z
  .string()
  .trim()
  .max(10, 'Currency must be at most 10 characters')
  .optional()
  .transform((value) => (value === '' ? undefined : value));

export const listPartiesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  party_type: z.enum(partyTypeValues).optional(),
  is_active: z
    .enum(['true', 'false'])
    .optional()
    .transform((value) => (value === undefined ? undefined : value === 'true')),
  sort: z.enum(sortFieldValues).default('name'),
  order: z.enum(sortOrderValues).default('asc'),
});

export type ListPartiesQuery = z.infer<typeof listPartiesQuerySchema>;

export const createPartyBodySchema = z.object({
  name: z.string().trim().min(1, 'Party name is required').max(200),
  legal_name: optionalText(200),
  alias: optionalText(200),
  mobile: requiredMobile,
  additional_phones: additionalPhonesField,
  email: optionalEmail,
  gstin: optionalGstin,
  party_type: z.enum(partyTypeValues).default('customer'),
  party_category: z.enum(partyCategoryValues).optional(),
  party_group: optionalText(100),
  area_code: optionalText(50),
  pricing_tier: pricingTierInput.optional(),
  default_price_tier: pricingTierInput.optional(),
  state_code: z
    .string()
    .trim()
    .max(4)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  state: z
    .string()
    .trim()
    .max(100)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  area_id: z.uuid('Invalid area ID').optional(),
  credit_limit: moneyField,
  opening_balance: moneyField,
  notes: z
    .string()
    .trim()
    .max(2000)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  currency: optionalCurrency,
  is_active: z.boolean().optional().default(true),
});

export type CreatePartyBody = z.infer<typeof createPartyBodySchema>;

export const updatePartyBodySchema = createPartyBodySchema
  .extend({
    mobile: optionalMobile,
  })
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdatePartyBody = z.infer<typeof updatePartyBodySchema>;

export const partyIdParamSchema = z.object({
  id: z.uuid('Invalid party ID'),
});

export type PartyIdParam = z.infer<typeof partyIdParamSchema>;
