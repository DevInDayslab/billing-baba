import { z } from 'zod';

const sortFieldValues = ['name', 'created_at'] as const;
const sortOrderValues = ['asc', 'desc'] as const;

export const listCategoriesQuerySchema = z.object({
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

export type ListCategoriesQuery = z.infer<typeof listCategoriesQuerySchema>;

export const createCategoryBodySchema = z.object({
  name: z.string().trim().min(1, 'Category name is required').max(200),
});

export type CreateCategoryBody = z.infer<typeof createCategoryBodySchema>;

export const updateCategoryBodySchema = createCategoryBodySchema
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateCategoryBody = z.infer<typeof updateCategoryBodySchema>;

export const categoryIdParamSchema = z.object({
  id: z.uuid('Invalid category ID'),
});

export type CategoryIdParam = z.infer<typeof categoryIdParamSchema>;
