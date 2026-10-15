import { z } from 'zod';

const sortFieldValues = ['name', 'created_at', 'opening_balance_as_of'] as const;
const sortOrderValues = ['asc', 'desc'] as const;
const moneyPattern = /^\d+(\.\d{1,4})?$/;

export const listLoanAccountsQuerySchema = z.object({
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

export type ListLoanAccountsQuery = z.infer<typeof listLoanAccountsQuerySchema>;

export const createLoanAccountBodySchema = z.object({
  name: z.string().trim().min(1, 'Loan account name is required').max(200),
  lender_name: z.string().trim().max(200).optional().nullable(),
  account_number: z.string().trim().max(100).optional().nullable(),
  description: z.string().trim().max(2000).optional().nullable(),
  opening_outstanding: z
    .string()
    .regex(moneyPattern, 'Invalid opening outstanding')
    .optional(),
  opening_balance_as_of: z.string().date('Invalid opening balance date'),
  interest_rate: z
    .string()
    .regex(moneyPattern, 'Invalid interest rate')
    .optional()
    .nullable(),
  term_months: z.coerce.number().int().min(1).max(600).optional().nullable(),
  received_bank_account_id: z.uuid('Invalid bank account ID').optional().nullable(),
});

export type CreateLoanAccountBody = z.infer<typeof createLoanAccountBodySchema>;

export const updateLoanAccountBodySchema = createLoanAccountBodySchema
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateLoanAccountBody = z.infer<typeof updateLoanAccountBodySchema>;

export const loanAccountIdParamSchema = z.object({
  id: z.uuid('Invalid loan account ID'),
});
