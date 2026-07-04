import { z } from 'zod';

const sortFieldValues = ['quantity', 'created_at'] as const;
const sortOrderValues = ['asc', 'desc'] as const;

const booleanQuery = z
  .union([z.boolean(), z.string()])
  .optional()
  .transform((value) => {
    if (value === undefined || value === '') return undefined;
    if (typeof value === 'boolean') return value;
    return value === 'true';
  });

export const listStockLevelsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  item_id: z.uuid('Invalid item ID').optional(),
  godown_id: z.uuid('Invalid godown ID').optional(),
  low_stock: booleanQuery,
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  sort: z.enum(sortFieldValues).default('quantity'),
  order: z.enum(sortOrderValues).default('asc'),
});

export type ListStockLevelsQuery = z.infer<typeof listStockLevelsQuerySchema>;

export const stockLevelIdParamSchema = z.object({
  id: z.uuid('Invalid stock level ID'),
});

export type StockLevelIdParam = z.infer<typeof stockLevelIdParamSchema>;
