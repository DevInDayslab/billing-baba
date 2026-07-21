import { z } from 'zod';

export const listHiddenLedgerEntriesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  party_id: z.uuid().optional(),
  status: z.enum(['pending', 'partial', 'recovered'] as const).optional(),
  from: z.iso.datetime().optional(),
  to: z.iso.datetime().optional(),
  q: z.string().trim().min(1).max(200).optional(),
  invoice_number: z.string().trim().min(1).max(100).optional(),
  sort: z.enum(['created_at', 'amount'] as const).default('created_at'),
  order: z.enum(['asc', 'desc'] as const).default('desc'),
});

export type ListHiddenLedgerEntriesQuery = z.infer<
  typeof listHiddenLedgerEntriesQuerySchema
>;

export const hiddenLedgerEntryIdParamSchema = z.object({
  id: z.uuid('Invalid hidden ledger entry ID'),
});

export const hiddenLedgerPartyIdParamSchema = z.object({
  partyId: z.uuid('Invalid party ID'),
});

export const listHiddenLedgerRecoveriesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type ListHiddenLedgerRecoveriesQuery = z.infer<
  typeof listHiddenLedgerRecoveriesQuerySchema
>;

const moneyString = z
  .string()
  .trim()
  .regex(/^\d+(\.\d{1,4})?$/, 'Invalid money value');

export const recoverFromSaleBodySchema = z.object({
  sale_id: z.uuid(),
  amount: moneyString,
});

export type RecoverFromSaleBody = z.infer<typeof recoverFromSaleBodySchema>;
