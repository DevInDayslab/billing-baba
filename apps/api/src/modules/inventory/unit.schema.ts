import { z } from 'zod';

const sortFieldValues = ['name', 'short_name', 'created_at'] as const;
const sortOrderValues = ['asc', 'desc'] as const;

export const listUnitsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  is_active: z
    .enum(['true', 'false'])
    .optional()
    .transform((value) => (value === undefined ? undefined : value === 'true')),
  sort: z.enum(sortFieldValues).default('name'),
  order: z.enum(sortOrderValues).default('asc'),
});

export type ListUnitsQuery = z.infer<typeof listUnitsQuerySchema>;

export const createUnitBodySchema = z.object({
  name: z.string().trim().min(1, 'Unit name is required').max(100),
  short_name: z.string().trim().min(1, 'Short name is required').max(20),
  symbol: z
    .string()
    .trim()
    .max(10)
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  decimal_places: z.coerce.number().int().min(0).max(6).default(0),
  is_system: z.boolean().optional().default(false),
  is_active: z.boolean().optional().default(true),
});

export type CreateUnitBody = z.infer<typeof createUnitBodySchema>;

export const updateUnitBodySchema = createUnitBodySchema
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateUnitBody = z.infer<typeof updateUnitBodySchema>;

export const unitIdParamSchema = z.object({
  id: z.uuid('Invalid unit ID'),
});

export type UnitIdParam = z.infer<typeof unitIdParamSchema>;

const moneyField = z
  .union([z.string(), z.number()])
  .transform((value) => String(value).trim())
  .pipe(
    z
      .string()
      .regex(/^\d+(\.\d{1,4})?$/, 'Must be a valid positive decimal amount'),
  );

export const listUnitConversionsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  from_unit_id: z.uuid('Invalid from unit ID').optional(),
  to_unit_id: z.uuid('Invalid to unit ID').optional(),
});

export type ListUnitConversionsQuery = z.infer<
  typeof listUnitConversionsQuerySchema
>;

export const createUnitConversionBodySchema = z.object({
  from_unit_id: z.uuid('Invalid from unit ID'),
  to_unit_id: z.uuid('Invalid to unit ID'),
  conversion_factor: moneyField.refine((value) => Number(value) > 0, {
    message: 'Conversion factor must be greater than 0',
  }),
});

export type CreateUnitConversionBody = z.infer<
  typeof createUnitConversionBodySchema
>;

export const updateUnitConversionBodySchema = z
  .object({
    from_unit_id: z.uuid('Invalid from unit ID').optional(),
    to_unit_id: z.uuid('Invalid to unit ID').optional(),
    conversion_factor: moneyField
      .optional()
      .refine((value) => value === undefined || Number(value) > 0, {
        message: 'Conversion factor must be greater than 0',
      }),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateUnitConversionBody = z.infer<
  typeof updateUnitConversionBodySchema
>;

export const unitConversionIdParamSchema = z.object({
  id: z.uuid('Invalid unit conversion ID'),
});

export type UnitConversionIdParam = z.infer<typeof unitConversionIdParamSchema>;
