import { z } from 'zod';

export const gstReportQuerySchema = z.object({
  period: z.string().optional(),
  from: z.string().optional(),
  to: z.string().optional(),
  financial_year: z.string().optional(),
  month: z.string().optional(),
  quarter: z.string().optional(),
  non_tax_as_exempt: z
    .union([z.boolean(), z.string()])
    .optional()
    .transform((value) => {
      if (value === undefined) return false;
      if (typeof value === 'boolean') return value;
      return value === 'true' || value === '1';
    }),
  format: z.enum(['json', 'gstn_json', 'csv']).optional(),
});

export type GstReportQuery = z.infer<typeof gstReportQuerySchema>;
