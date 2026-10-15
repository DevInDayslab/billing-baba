import { z } from 'zod';

const sortFieldValues = ['name', 'created_at'] as const;
const sortOrderValues = ['asc', 'desc'] as const;
const categoryTypeValues = ['direct', 'indirect'] as const;

export const listIncomeCategoriesQuerySchema = z.object({
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

export type ListIncomeCategoriesQuery = z.infer<
  typeof listIncomeCategoriesQuerySchema
>;

export const createIncomeCategoryBodySchema = z.object({
  name: z.string().trim().min(1, 'Category name is required').max(200),
  category_type: z.enum(categoryTypeValues).default('direct'),
});

export type CreateIncomeCategoryBody = z.infer<
  typeof createIncomeCategoryBodySchema
>;

export const updateIncomeCategoryBodySchema = z
  .object({
    name: z.string().trim().min(1).max(200).optional(),
    category_type: z.enum(categoryTypeValues).optional(),
  })
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateIncomeCategoryBody = z.infer<
  typeof updateIncomeCategoryBodySchema
>;

export const incomeCategoryIdParamSchema = z.object({
  id: z.uuid('Invalid category ID'),
});
