import type { GeneratedDocumentRecord } from './generated-document.types';

export function toGeneratedDocumentResponse(
  row: GeneratedDocumentRecord,
  options: {
    cached: boolean;
    downloadUrl?: string;
    publicUrl?: string;
  },
) {
  return {
    id: row.id,
    document_kind: row.documentKind,
    source_type: row.sourceType,
    source_id: row.sourceId,
    source_version: row.sourceVersion,
    file_name: row.fileName,
    mime_type: row.mimeType,
    public_token: row.publicToken,
    cached: options.cached,
    generated_at: row.generatedAt.toISOString(),
    ...(options.downloadUrl ? { download_url: options.downloadUrl } : {}),
    ...(options.publicUrl ? { public_url: options.publicUrl } : {}),
  };
}
