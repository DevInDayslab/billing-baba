import { z } from 'zod';
import { STORAGE_PURPOSES, STORAGE_VISIBILITIES } from './storage.constants';

export const createUploadIntentBodySchema = z.object({
  purpose: z.enum(STORAGE_PURPOSES),
  visibility: z.enum(STORAGE_VISIBILITIES).default('private'),
  mime_type: z.string().trim().min(1, 'mime_type is required'),
  file_size: z.coerce
    .number()
    .int()
    .positive('file_size must be a positive integer'),
  owner_type: z.string().trim().min(1).max(64).optional().nullable(),
  owner_id: z.uuid('owner_id must be a valid UUID').optional().nullable(),
  checksum: z.string().trim().min(1).max(128).optional().nullable(),
});

export type CreateUploadIntentBody = z.infer<
  typeof createUploadIntentBodySchema
>;

export const completeUploadBodySchema = z.object({
  intent_id: z.uuid('intent_id must be a valid UUID'),
});

export type CompleteUploadBody = z.infer<typeof completeUploadBodySchema>;

export const storageFileIdParamSchema = z.object({
  id: z.uuid('Invalid file ID'),
});
