import { z } from 'zod';

const phoneSchema = z
  .string()
  .trim()
  .regex(/^\d{10}$/, 'Phone must be a 10-digit mobile number.');

const deviceIdSchema = z.string().uuid('device_id must be a valid UUID');

export const loginBodySchema = z
  .object({
    access_token: z.string().min(1, 'access_token is required'),
    /** 10-digit mobile from the login form — used when MSG91 verify omits phone. */
    phone: phoneSchema.optional(),
    remember_for_30_days: z.boolean().optional().default(false),
    device_id: deviceIdSchema.optional(),
  })
  .superRefine((body, ctx) => {
    if (body.remember_for_30_days && !body.device_id) {
      ctx.addIssue({
        code: 'custom',
        message: 'device_id is required when remember_for_30_days is true',
        path: ['device_id'],
      });
    }
  });

export const deviceTrustLoginBodySchema = z.object({
  phone: phoneSchema,
  device_id: deviceIdSchema,
  device_trust_token: z.string().min(1, 'device_trust_token is required'),
});

export const refreshBodySchema = z.object({
  refresh_token: z.string().min(1, 'refresh_token is required'),
  business_id: z.string().uuid().optional(),
});

export const logoutBodySchema = z.object({
  refresh_token: z.string().min(1, 'refresh_token is required'),
});

export type LoginBody = z.infer<typeof loginBodySchema>;
export type DeviceTrustLoginBody = z.infer<typeof deviceTrustLoginBodySchema>;
export type RefreshBody = z.infer<typeof refreshBodySchema>;
export type LogoutBody = z.infer<typeof logoutBodySchema>;
