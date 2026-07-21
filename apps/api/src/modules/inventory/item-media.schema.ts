import { z } from 'zod';

export const itemImageUploadBodySchema = z.union([
  z.object({
    mime_type: z.string().min(1),
    file_size: z.number().int().positive(),
    checksum: z.string().optional().nullable(),
  }),
  z.object({
    intent_id: z.uuid(),
    is_primary: z.boolean().optional(),
    sort_order: z.coerce.number().int().min(0).optional(),
    replaces_image_id: z.uuid().optional(),
  }),
  z.object({
    image_url: z.string().trim().url('Invalid image URL'),
    sort_order: z.coerce.number().int().min(0).optional().default(0),
    is_primary: z.boolean().optional().default(false),
  }),
]);

export type ItemImageUploadBody = z.infer<typeof itemImageUploadBodySchema>;

export const reorderItemImagesBodySchema = z.object({
  image_ids: z.array(z.uuid()).min(1),
});

export type ReorderItemImagesBody = z.infer<typeof reorderItemImagesBodySchema>;

export const rackPhotoUploadBodySchema = z.union([
  z.object({
    mime_type: z.string().min(1),
    file_size: z.number().int().positive(),
    checksum: z.string().optional().nullable(),
  }),
  z.object({
    intent_id: z.uuid(),
  }),
]);

export type RackPhotoUploadBody = z.infer<typeof rackPhotoUploadBodySchema>;
