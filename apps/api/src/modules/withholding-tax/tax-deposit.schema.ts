import { z } from 'zod';

const moneyString = z
  .string()
  .trim()
  .regex(/^\d+(\.\d{1,4})?$/, 'Invalid money value');

export const createTaxDepositBodySchema = z.object({
  kind: z.enum(['tds', 'tcs']),
  bsr_code: z.string().trim().min(3).max(20),
  challan_serial: z.string().trim().min(1).max(50),
  deposit_date: z.string().date(),
  amount: moneyString,
  notes: z.string().trim().max(2000).optional().nullable(),
  entry_ids: z.array(z.uuid()).optional(),
  bank_account_id: z.string().uuid().optional().nullable(),
});

export const taxDepositIdParamSchema = z.object({
  id: z.string().uuid(),
});

export type CreateTaxDepositBody = z.infer<typeof createTaxDepositBodySchema>;

export const listTaxDepositsQuerySchema = z.object({
  kind: z.enum(['tds', 'tcs']).optional(),
});
