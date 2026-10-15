import { z } from 'zod';

const moneyString = z
  .string()
  .trim()
  .regex(/^\d+(\.\d{1,4})?$/, 'Invalid money value');

const dateKey = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date');

export const createBankAccountBodySchema = z.object({
  display_name: z.string().trim().min(1).max(120),
  bank_name: z.string().trim().max(120).optional().nullable(),
  account_number: z.string().trim().max(40).optional().nullable(),
  ifsc: z.string().trim().max(11).optional().nullable(),
  upi_id: z.string().trim().max(100).optional().nullable(),
  opening_balance: moneyString.optional(),
  opening_balance_as_of: dateKey.optional(),
  is_default: z.boolean().optional(),
});

export const updateBankAccountBodySchema = createBankAccountBodySchema
  .partial()
  .extend({
    is_active: z.boolean().optional(),
  });

export const updateCashOpeningBodySchema = z.object({
  opening_balance: moneyString,
  opening_balance_as_of: dateKey.optional(),
});

export const createTransferBodySchema = z.object({
  from_account_id: z.string().uuid(),
  to_account_id: z.string().uuid(),
  amount: moneyString,
  transfer_date: dateKey,
  notes: z.string().trim().max(500).optional().nullable(),
});

export const createAdjustmentBodySchema = z.object({
  bank_account_id: z.string().uuid(),
  kind: z.enum(['increase', 'decrease']),
  amount: moneyString,
  adjustment_date: dateKey,
  notes: z.string().trim().max(500).optional().nullable(),
});

export const bankStatementQuerySchema = z.object({
  bank_account_id: z.string().uuid(),
  period: z.string().optional(),
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
});

export const bankAccountIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const transferIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const adjustmentIdParamSchema = z.object({
  id: z.string().uuid(),
});
