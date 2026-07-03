import { z } from 'zod';

const sortFieldValues = ['name', 'created_at'] as const;
const sortOrderValues = ['asc', 'desc'] as const;

export const listGodownsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  sort: z.enum(sortFieldValues).default('name'),
  order: z.enum(sortOrderValues).default('asc'),
});

export type ListGodownsQuery = z.infer<typeof listGodownsQuerySchema>;

export const createGodownBodySchema = z.object({
  name: z.string().trim().min(1, 'Godown name is required').max(200),
  address: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
});

export type CreateGodownBody = z.infer<typeof createGodownBodySchema>;

export const updateGodownBodySchema = z
  .object({
    name: z
      .string()
      .trim()
      .min(1, 'Godown name is required')
      .max(200)
      .optional(),
    address: z
      .string()
      .trim()
      .nullable()
      .optional()
      .transform((value) => (value === '' ? null : value)),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateGodownBody = z.infer<typeof updateGodownBodySchema>;

export const godownIdParamSchema = z.object({
  id: z.uuid('Invalid godown ID'),
});

export type GodownIdParam = z.infer<typeof godownIdParamSchema>;
