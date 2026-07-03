import { z } from 'zod';

export const loginBodySchema = z.object({
  access_token: z.string().min(1, 'access_token is required'),
  /** 10-digit mobile from the login form — used when MSG91 verify omits phone. */
  phone: z
    .string()
    .trim()
    .regex(/^\d{10}$/, 'Phone must be a 10-digit mobile number.')
    .optional(),
});

export const refreshBodySchema = z.object({
  refresh_token: z.string().min(1, 'refresh_token is required'),
  business_id: z.string().uuid().optional(),
});

export const logoutBodySchema = z.object({
  refresh_token: z.string().min(1, 'refresh_token is required'),
});

export type LoginBody = z.infer<typeof loginBodySchema>;
export type RefreshBody = z.infer<typeof refreshBodySchema>;
export type LogoutBody = z.infer<typeof logoutBodySchema>;
