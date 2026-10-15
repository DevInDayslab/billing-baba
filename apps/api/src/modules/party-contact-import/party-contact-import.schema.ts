import { z } from 'zod';

export const partyContactImportSessionIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const partyContactImportTokenParamSchema = z.object({
  token: z.string().min(16).max(128),
});

const stagingContactSchema = z.object({
  display_name: z.string().trim().min(1).max(200),
  phones: z.array(z.string().trim().min(1)).min(1).max(10),
  email: z.string().trim().email().optional().nullable(),
  address: z.string().trim().max(500).optional().nullable(),
});

export const replacePartyContactImportStagingBodySchema = z.object({
  contacts: z.array(stagingContactSchema).max(500),
});

export type ReplacePartyContactImportStagingBody = z.infer<
  typeof replacePartyContactImportStagingBodySchema
>;
