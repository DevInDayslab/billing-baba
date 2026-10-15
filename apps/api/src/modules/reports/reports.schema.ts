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

export const partyGroupSchema = z.enum([
  'customer',
  'retailer',
  'wholesaler',
  'manufacturer',
  'custom',
]);

export const paymentModeSchema = z.enum([
  'cash',
  'upi',
  'card',
  'cheque',
  'bank_transfer',
  'other',
]);

export const reportFormatSchema = z.enum(['json', 'csv']).default('json');

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
  format: reportFormatSchema.optional(),
});

export const partyTypeFilterSchema = z.enum(['customer', 'supplier', 'both']);

export const reportExtendedQuerySchema = reportBaseQuerySchema.extend({
  category_id: z.string().uuid().optional(),
  payment_mode: paymentModeSchema.optional(),
  document_type: z.string().trim().optional(),
  party_group: partyGroupSchema.optional(),
  party_type: partyTypeFilterSchema.optional(),
  bank_name: z.string().trim().optional(),
  tax_rate: z.coerce.number().min(0).optional(),
  loan_account: z.string().trim().optional(),
  status: z.string().trim().optional(),
  in_stock_only: z
    .enum(['true', 'false'])
    .optional()
    .transform((value) => value === 'true'),
});

export const reportDateQuerySchema = reportExtendedQuerySchema.extend({
  date: z.string().datetime().optional(),
});

export const partyStatementQuerySchema = reportExtendedQuerySchema.extend({
  party_id: z.string().uuid(),
});

export const loanStatementQuerySchema = reportExtendedQuerySchema.extend({
  loan_account: z.string().trim().min(1),
});

export const businessBankStatementQuerySchema =
  reportExtendedQuerySchema.extend({
    bank_account_id: z.string().uuid(),
  });

export type ReportBaseQuery = z.infer<typeof reportBaseQuerySchema>;
export type ReportExtendedQuery = z.infer<typeof reportExtendedQuerySchema>;
export type ReportDateQuery = z.infer<typeof reportDateQuerySchema>;
export type PartyStatementQuery = z.infer<typeof partyStatementQuerySchema>;
export type LoanStatementQuery = z.infer<typeof loanStatementQuerySchema>;
export type BusinessBankStatementQuery = z.infer<
  typeof businessBankStatementQuerySchema
>;
