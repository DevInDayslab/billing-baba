import type { ImageVariantRecord, ImageVariantResponse } from './image.types';

export function toImageVariantResponse(
  record: ImageVariantRecord,
  url: string,
  cdnUrl: string | null,
  expiresAt: string | null,
): ImageVariantResponse {
  return {
    variant: record.variant,
    media_asset_id: record.mediaAssetId,
    width: record.width,
    height: record.height,
    file_size: record.fileSize,
    mime_type: record.mimeType,
    url,
    cdn_url: cdnUrl,
    expires_at: expiresAt,
  };
}
