import type {
  StorageAssetStatus,
  StoragePurpose,
  StorageVisibility,
} from './storage.constants';
import type {
  MediaAssetRow,
  StorageAsset,
  UploadIntent,
} from './storage.types';

export function toStorageAsset(row: MediaAssetRow): StorageAsset {
  return {
    id: row.id,
    businessId: row.businessId,
    storageKey: row.storageKey,
    bucket: row.bucket,
    purpose: row.purpose as StoragePurpose,
    visibility: row.visibility as StorageVisibility,
    mimeType: row.mimeType,
    fileSize: row.fileSize,
    etag: row.etag,
    checksum: row.checksum,
    ownerType: row.ownerType,
    ownerId: row.ownerId,
    status: row.status as StorageAssetStatus,
    uploadedBy: row.uploadedBy,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

/** Snake_case API payload for StorageAsset. */
export function toStorageAssetResponse(asset: StorageAsset) {
  return {
    id: asset.id,
    business_id: asset.businessId,
    storage_key: asset.storageKey,
    bucket: asset.bucket,
    purpose: asset.purpose,
    visibility: asset.visibility,
    mime_type: asset.mimeType,
    file_size: asset.fileSize,
    etag: asset.etag,
    checksum: asset.checksum,
    owner_type: asset.ownerType,
    owner_id: asset.ownerId,
    status: asset.status,
    uploaded_by: asset.uploadedBy,
    created_at: asset.createdAt,
    updated_at: asset.updatedAt,
  };
}

export function toUploadIntentResponse(intent: UploadIntent) {
  return {
    intent_id: intent.intentId,
    upload_url: intent.uploadUrl,
    storage_key: intent.storageKey,
    headers: intent.headers,
    expires_at: intent.expiresAt,
    max_bytes: intent.maxBytes,
    mime_type: intent.mimeType,
  };
}
