import { z } from 'zod';
import { DOCUMENT_ATTACHMENT_ENTITY_TYPES } from './document-attachment.constants';

export const documentAttachmentEntityTypeSchema = z.enum(
  DOCUMENT_ATTACHMENT_ENTITY_TYPES,
);

export const listDocumentAttachmentsQuerySchema = z.object({
  entity_type: documentAttachmentEntityTypeSchema,
  entity_id: z.uuid(),
});

export const documentAttachmentUploadBodySchema = z.union([
  z.object({
    mime_type: z.string().min(1),
    file_size: z.number().int().positive(),
    checksum: z.string().optional().nullable(),
    file_name: z.string().trim().min(1).max(255).optional(),
    label: z.string().trim().max(255).optional().nullable(),
  }),
  z.object({
    intent_id: z.uuid(),
    file_name: z.string().trim().min(1).max(255),
    label: z.string().trim().max(255).optional().nullable(),
    sort_order: z.coerce.number().int().min(0).optional(),
    replaces_attachment_id: z.uuid().optional(),
  }),
]);

export const documentAttachmentIdParamSchema = z.object({
  id: z.uuid(),
});

export const updateDocumentAttachmentBodySchema = z.object({
  label: z.string().trim().max(255).optional().nullable(),
  file_name: z.string().trim().min(1).max(255).optional(),
});
