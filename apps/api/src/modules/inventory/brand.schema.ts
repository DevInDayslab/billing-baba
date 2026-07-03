import { z } from 'zod';

const sortFieldValues = ['name', 'created_at'] as const;
const sortOrderValues = ['asc', 'desc'] as const;

export const listBrandsQuerySchema = z.object({
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

export type ListBrandsQuery = z.infer<typeof listBrandsQuerySchema>;

export const createBrandBodySchema = z.object({
  name: z.string().trim().min(1, 'Brand name is required').max(200),
});

export type CreateBrandBody = z.infer<typeof createBrandBodySchema>;

export const updateBrandBodySchema = createBrandBodySchema
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateBrandBody = z.infer<typeof updateBrandBodySchema>;

export const brandIdParamSchema = z.object({
  id: z.uuid('Invalid brand ID'),
});

export type BrandIdParam = z.infer<typeof brandIdParamSchema>;
