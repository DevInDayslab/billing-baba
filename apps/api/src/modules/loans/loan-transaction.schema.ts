import { z } from 'zod';

const sortFieldValues = ['transaction_date', 'created_at'] as const;
const sortOrderValues = ['asc', 'desc'] as const;
const transactionTypeValues = ['increase', 'repayment', 'charges'] as const;
const moneyPattern = /^\d+(\.\d{1,4})?$/;

export const listLoanTransactionsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  loan_account_id: z.uuid().optional(),
  transaction_type: z.enum(transactionTypeValues).optional(),
  from: z.string().date().optional(),
  to: z.string().date().optional(),
  q: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  sort: z.enum(sortFieldValues).default('transaction_date'),
  order: z.enum(sortOrderValues).default('desc'),
});

export type ListLoanTransactionsQuery = z.infer<
  typeof listLoanTransactionsQuerySchema
>;

export const createLoanTransactionBodySchema = z.object({
  loan_account_id: z.uuid('Invalid loan account ID'),
  transaction_type: z.enum(transactionTypeValues),
  transaction_date: z.string().date('Invalid transaction date'),
  principal_amount: z
    .string()
    .regex(moneyPattern, 'Invalid principal amount')
    .optional(),
  interest_amount: z
    .string()
    .regex(moneyPattern, 'Invalid interest amount')
    .optional(),
  charges_amount: z
    .string()
    .regex(moneyPattern, 'Invalid charges amount')
    .optional(),
  bank_account_id: z.uuid('Invalid bank account ID'),
  description: z.string().trim().max(2000).optional().nullable(),
  reference_number: z.string().trim().max(100).optional().nullable(),
});

export type CreateLoanTransactionBody = z.infer<
  typeof createLoanTransactionBodySchema
>;

export const updateLoanTransactionBodySchema = createLoanTransactionBodySchema
  .partial()
  .refine((body) => Object.keys(body).length > 0, {
    message: 'At least one field is required',
  });

export type UpdateLoanTransactionBody = z.infer<
  typeof updateLoanTransactionBodySchema
>;

export const loanTransactionIdParamSchema = z.object({
  id: z.uuid('Invalid loan transaction ID'),
});
