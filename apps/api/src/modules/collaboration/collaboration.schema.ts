import { z } from 'zod';

const collaborationRoleSchema = z.enum([
  'secondary_admin',
  'salesman',
  'biller',
  'biller_and_salesman',
  'accountant',
  'accountant_edit_access',
  'stock_keeper',
]);

export const createInvitationBodySchema = z.object({
  full_name: z.string().trim().min(1, 'Full name is required').max(200),
  phone_or_email: z
    .string()
    .trim()
    .min(3, 'Phone or email is required')
    .max(200),
  role: collaborationRoleSchema,
});

export const invitationTokenParamsSchema = z.object({
  token: z.string().min(1),
});

export const invitationIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export const companyMemberIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export type CreateInvitationBody = z.infer<typeof createInvitationBodySchema>;
