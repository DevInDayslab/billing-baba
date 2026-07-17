import { z } from 'zod';
import {
  normalizePricingTier,
  PRICING_TIER_INPUT_VALUES,
} from '../../shared/pricing/pricing-tier';

const sortFieldValues = ['name', 'created_at'] as const;
const sortOrderValues = ['asc', 'desc'] as const;
const itemTypeValues = ['product', 'service'] as const;

const moneyField = z
  .union([z.string(), z.number()])
  .transform((value) => String(value).trim())
  .pipe(
    z
      .string()
      .regex(/^\d+(\.\d{1,4})?$/, 'Must be a valid positive decimal amount'),
  );

const optionalMoneyField = z
  .union([z.string(), z.number()])
  .optional()
  .transform((value) =>
    value === undefined || value === '' ? undefined : String(value).trim(),
  )
  .pipe(
    z
      .string()
      .regex(/^\d+(\.\d{1,4})?$/, 'Must be a valid positive decimal amount')
      .optional(),
  );

const tierPriceSchema = z.object({
  pricing_tier: z
    .enum(PRICING_TIER_INPUT_VALUES)
    .transform((value) => normalizePricingTier(value)),
  price: moneyField,
});

const tierPricesArraySchema = z.array(tierPriceSchema).refine(
  (tierPrices) => {
    const tiers = tierPrices.map((tier) => tier.pricing_tier);
    return new Set(tiers).size === tiers.length;
  },
  {
    message: 'Each pricing tier may only appear once',
  },
);

const locationSchema = z.object({
  godown_id: z.uuid('Invalid godown ID'),
  rack: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  shelf: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
});

export const listItemsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  type: z.enum(itemTypeValues).optional(),
  category_id: z.uuid('Invalid category ID').optional(),
  brand_id: z.uuid('Invalid brand ID').optional(),
  hsn: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  barcode: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  sort: z.enum(sortFieldValues).default('name'),
  order: z.enum(sortOrderValues).default('asc'),
});

export type ListItemsQuery = z.infer<typeof listItemsQuerySchema>;

export const createItemBodySchema = z.object({
  name: z.string().trim().min(1, 'Item name is required').max(300),
  description: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  item_type: z.enum(itemTypeValues).default('product'),
  hsn_code: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  barcode: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  category_id: z.uuid('Invalid category ID').optional(),
  brand_id: z.uuid('Invalid brand ID').optional(),
  base_unit: z.string().trim().min(1, 'Base unit is required').max(20),
  sale_price: moneyField.default('0'),
  purchase_price: moneyField.default('0'),
  mrp: optionalMoneyField,
  market_price: optionalMoneyField,
  reorder_level: optionalMoneyField,
  has_stock_tracking: z.boolean().optional().default(true),
  tier_prices: tierPricesArraySchema.optional().default([]),
  primary_image_url: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  opening_quantity: optionalMoneyField,
  opening_cost_per_unit: optionalMoneyField,
  opening_godown_id: z.uuid('Invalid godown ID').optional(),
  location: locationSchema.optional(),
});

export type CreateItemBody = z.infer<typeof createItemBodySchema>;

export const updateItemBodySchema = z
  .object({
    name: z.string().trim().min(1, 'Item name is required').max(300).optional(),
    description: z
      .string()
      .trim()
      .nullable()
      .optional()
      .transform((value) => (value === '' ? null : value)),
    item_type: z.enum(itemTypeValues).optional(),
    hsn_code: z
      .string()
      .trim()
      .nullable()
      .optional()
      .transform((value) => (value === '' ? null : value)),
    barcode: z
      .string()
      .trim()
      .nullable()
      .optional()
      .transform((value) => (value === '' ? null : value)),
    category_id: z.uuid('Invalid category ID').nullable().optional(),
    brand_id: z.uuid('Invalid brand ID').nullable().optional(),
    base_unit: z.string().trim().min(1).max(20).optional(),
    sale_price: moneyField.optional(),
    purchase_price: moneyField.optional(),
    mrp: optionalMoneyField.nullable(),
    market_price: optionalMoneyField.nullable(),
    reorder_level: optionalMoneyField.nullable(),
    has_stock_tracking: z.boolean().optional(),
    tier_prices: tierPricesArraySchema.optional(),
    primary_image_url: z
      .string()
      .trim()
      .nullable()
      .optional()
      .transform((value) => (value === '' ? null : value)),
    opening_quantity: optionalMoneyField,
    opening_cost_per_unit: optionalMoneyField,
    opening_godown_id: z.uuid('Invalid godown ID').optional(),
    location: locationSchema.optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateItemBody = z.infer<typeof updateItemBodySchema>;

export const itemIdParamSchema = z.object({
  id: z.uuid('Invalid item ID'),
});

export type ItemIdParam = z.infer<typeof itemIdParamSchema>;

export const createItemImageBodySchema = z.object({
  image_url: z.string().trim().url('Invalid image URL'),
  sort_order: z.coerce.number().int().min(0).optional().default(0),
  is_primary: z.boolean().optional().default(false),
});

export type CreateItemImageBody = z.infer<typeof createItemImageBodySchema>;

export const itemImageParamSchema = z.object({
  id: z.uuid('Invalid item ID'),
  imageId: z.uuid('Invalid image ID'),
});

export type ItemImageParam = z.infer<typeof itemImageParamSchema>;

export const updateItemImageBodySchema = z
  .object({
    image_url: z.string().trim().url('Invalid image URL').optional(),
    sort_order: z.coerce.number().int().min(0).optional(),
    is_primary: z.boolean().optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateItemImageBody = z.infer<typeof updateItemImageBodySchema>;

export const putItemTierPricesBodySchema = z.object({
  tier_prices: tierPricesArraySchema,
});

export type PutItemTierPricesBody = z.infer<typeof putItemTierPricesBodySchema>;

export const itemTierParamSchema = z.object({
  id: z.uuid('Invalid item ID'),
  tier: z
    .enum(PRICING_TIER_INPUT_VALUES)
    .transform((value) => normalizePricingTier(value)),
});

export type ItemTierParam = z.infer<typeof itemTierParamSchema>;

export const listItemPriceHistoryQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type ListItemPriceHistoryQuery = z.infer<
  typeof listItemPriceHistoryQuerySchema
>;
