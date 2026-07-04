import { z } from 'zod';

export const reportPeriodSchema = z.enum([
  'today',
  'yesterday',
  'this_week',
  'last_week',
  'this_month',
  'last_month',
  'this_quarter',
  'this_year',
  'all_time',
  'custom',
]);

export const reportBaseQuerySchema = z.object({
  period: reportPeriodSchema.optional(),
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  q: z.string().trim().optional(),
  party_id: z.string().uuid().optional(),
  godown_id: z.string().uuid().optional(),
  item_id: z.string().uuid().optional(),
  sort: z
    .enum(['date', 'document_date', 'amount', 'party_name', 'created_at'])
    .optional(),
  order: z.enum(['asc', 'desc']).optional(),
});

export const reportDateQuerySchema = reportBaseQuerySchema.extend({
  date: z.string().datetime().optional(),
});

export const partyStatementQuerySchema = reportBaseQuerySchema.extend({
  party_id: z.string().uuid(),
});

export type ReportBaseQuery = z.infer<typeof reportBaseQuerySchema>;
export type ReportDateQuery = z.infer<typeof reportDateQuerySchema>;
export type PartyStatementQuery = z.infer<typeof partyStatementQuerySchema>;
