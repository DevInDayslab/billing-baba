import { z } from 'zod';
import {
  GENERATED_DOCUMENT_KINDS,
  GENERATED_SOURCE_TYPES,
  GENERATED_DOCUMENT_MIME_TYPES,
} from './generated-document.constants';

export const lookupGeneratedDocumentQuerySchema = z.object({
  document_kind: z.enum(GENERATED_DOCUMENT_KINDS),
  source_type: z.enum(GENERATED_SOURCE_TYPES),
  source_id: z.string().uuid(),
});

export const ensureGeneratedDocumentBodySchema = z.object({
  document_kind: z.enum(GENERATED_DOCUMENT_KINDS),
  source_type: z.enum(GENERATED_SOURCE_TYPES),
  source_id: z.string().uuid(),
  file_name: z.string().trim().min(1).max(255),
  mime_type: z.enum(GENERATED_DOCUMENT_MIME_TYPES),
  content_base64: z.string().min(1),
  force_regenerate: z.boolean().optional(),
});

export const generatedDocumentIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const generatedDocumentPublicTokenParamSchema = z.object({
  token: z.string().min(16).max(128),
});

export const regenerateGeneratedDocumentBodySchema = z.object({
  file_name: z.string().trim().min(1).max(255),
  mime_type: z.enum(GENERATED_DOCUMENT_MIME_TYPES),
  content_base64: z.string().min(1),
});
