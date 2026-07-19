import { z } from 'zod';

export const brandingUploadBodySchema = z.union([
  z.object({
    mime_type: z.string().min(1),
    file_size: z.number().int().positive(),
    checksum: z.string().optional().nullable(),
  }),
  z.object({
    intent_id: z.string().uuid(),
  }),
]);

export type BrandingUploadBody = z.infer<typeof brandingUploadBodySchema>;

export const avatarUploadBodySchema = brandingUploadBodySchema;

export type AvatarUploadBody = z.infer<typeof avatarUploadBodySchema>;
