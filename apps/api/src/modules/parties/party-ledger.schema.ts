import { z } from 'zod';

const partyLedgerFilterValues = [
  'all',
  'sales',
  'purchases',
  'payments',
  'returns',
] as const;

export const partyLedgerQuerySchema = z.object({
  filter: z.enum(partyLedgerFilterValues).default('all'),
  from: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
  to: z
    .string()
    .trim()
    .optional()
    .transform((value) => (value === '' ? undefined : value)),
});

export type PartyLedgerQuery = z.infer<typeof partyLedgerQuerySchema>;
