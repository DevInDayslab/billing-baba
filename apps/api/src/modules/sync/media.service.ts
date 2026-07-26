import { randomUUID } from 'node:crypto';
import type {
  MediaUploadCompleteBody,
  MediaUploadIntentBody,
} from './sync.schema';

/**
 * Media sync stubs — intent/complete/url shapes only.
 * No object storage integration in this phase.
 */
export class MediaService {
  createUploadIntent(body: MediaUploadIntentBody): {
    intent_id: string;
    client_media_id: string;
    upload_url: string;
    headers: Record<string, string>;
    expires_at: string;
  } {
    const intentId = randomUUID();
    const expiresAt = new Date(Date.now() + 30 * 60 * 1000);
    return {
      intent_id: intentId,
      client_media_id: body.client_media_id,
      upload_url: `https://example.invalid/sync-media-stub/${intentId}`,
      headers: {
        'Content-Type': body.mime_type,
      },
      expires_at: expiresAt.toISOString(),
    };
  }

  completeUpload(body: MediaUploadCompleteBody): {
    media_asset_id: string;
    client_media_id: string;
    checksum_sha256: string;
    variants_status: string;
  } {
    return {
      media_asset_id: randomUUID(),
      client_media_id: body.client_media_id,
      checksum_sha256: body.checksum_sha256.toLowerCase(),
      variants_status: 'pending',
    };
  }

  getDownloadUrl(
    assetId: string,
    variant: 'thumbnail' | 'medium' | 'original',
  ): {
    asset_id: string;
    variant: string;
    url: string;
    expires_at: string;
  } {
    const expiresAt = new Date(Date.now() + 30 * 60 * 1000);
    return {
      asset_id: assetId,
      variant,
      url: `https://example.invalid/sync-media-stub/download/${assetId}?variant=${variant}`,
      expires_at: expiresAt.toISOString(),
    };
  }
}
