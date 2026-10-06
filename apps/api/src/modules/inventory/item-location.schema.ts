import { z } from 'zod';

const sortOrderValues = ['asc', 'desc'] as const;

export const listItemLocationsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  item_id: z.uuid('Invalid item ID').optional(),
  godown_id: z.uuid('Invalid godown ID').optional(),
  sort: z.literal('created_at').default('created_at'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListItemLocationsQuery = z.infer<
  typeof listItemLocationsQuerySchema
>;

const employeeLabelSchema = z
  .string()
  .trim()
  .max(120, 'Employee name or ID is too long')
  .optional()
  .transform((value) => (value === '' ? undefined : value));

export const createItemLocationBodySchema = z.object({
  item_id: z.uuid('Invalid item ID'),
  godown_id: z.uuid('Invalid godown ID'),
  employee_label: employeeLabelSchema,
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
  photo_url: z
    .string()
    .trim()
    .url('Invalid photo URL')
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
});

export type CreateItemLocationBody = z.infer<
  typeof createItemLocationBodySchema
>;

export const updateItemLocationBodySchema = z
  .object({
    godown_id: z.uuid('Invalid godown ID').optional(),
    employee_label: employeeLabelSchema,
    rack: z
      .string()
      .trim()
      .nullable()
      .optional()
      .transform((value) => (value === '' ? null : value)),
    shelf: z
      .string()
      .trim()
      .nullable()
      .optional()
      .transform((value) => (value === '' ? null : value)),
    photo_url: z
      .string()
      .trim()
      .url('Invalid photo URL')
      .nullable()
      .optional()
      .transform((value) => (value === '' ? null : value)),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateItemLocationBody = z.infer<
  typeof updateItemLocationBodySchema
>;

export const itemLocationIdParamSchema = z.object({
  id: z.uuid('Invalid item location ID'),
});

export type ItemLocationIdParam = z.infer<typeof itemLocationIdParamSchema>;

export const listItemLocationHistoryQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(50),
});

export type ListItemLocationHistoryQuery = z.infer<
  typeof listItemLocationHistoryQuerySchema
>;
