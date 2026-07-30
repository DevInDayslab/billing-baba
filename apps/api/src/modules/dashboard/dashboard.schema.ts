import { z } from 'zod';

const periodValues = [
  'today',
  'this_week',
  'this_month',
  'this_year',
  'all_time',
  'custom',
] as const;

export const dashboardQuerySchema = z.object({
  period: z.enum(periodValues).default('this_month'),
  from: z.iso.datetime({ offset: true }).optional(),
  to: z.iso.datetime({ offset: true }).optional(),
});

export type DashboardQuery = z.infer<typeof dashboardQuerySchema>;
