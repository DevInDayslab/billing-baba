import { z } from 'zod';
import { reportBaseQuerySchema } from '../reports/reports.schema';

export const gstFormalFilterSchema = z.enum(['all', 'formal', 'non_formal']);

export const gstRegisterTransactionTypeSchema = z.enum([
  'all',
  'sale',
  'purchase',
  'credit_note',
  'debit_note',
]);

export const taxReportQuerySchema = reportBaseQuerySchema.extend({
  gst_formal: gstFormalFilterSchema.optional().default('all'),
  transaction_type: gstRegisterTransactionTypeSchema.optional().default('all'),
});

export type TaxReportQuery = z.infer<typeof taxReportQuerySchema>;
