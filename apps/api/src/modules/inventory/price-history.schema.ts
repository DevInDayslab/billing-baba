import { z } from 'zod';

export const listPriceHistoryQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  item_id: z.uuid('Invalid item ID').optional(),
});

export type ListPriceHistoryQuery = z.infer<typeof listPriceHistoryQuerySchema>;

export const priceHistoryIdParamSchema = z.object({
  id: z.uuid('Invalid price history ID'),
});

export type PriceHistoryIdParam = z.infer<typeof priceHistoryIdParamSchema>;
