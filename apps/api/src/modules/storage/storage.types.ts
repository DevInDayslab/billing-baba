import type {
  StorageAssetStatus,
  StoragePurpose,
  StorageVisibility,
} from './storage.constants';

/** API / service-facing media asset metadata. */
export type StorageAsset = {
  id: string;
  businessId: string;
  storageKey: string;
  bucket: string;
  purpose: StoragePurpose;
  visibility: StorageVisibility;
  mimeType: string;
  fileSize: number;
  etag: string | null;
  checksum: string | null;
  ownerType: string | null;
  ownerId: string | null;
  status: StorageAssetStatus;
  uploadedBy: string | null;
  createdAt: string;
  updatedAt: string;
};

export type UploadIntent = {
  intentId: string;
  uploadUrl: string;
  storageKey: string;
  headers: Record<string, string>;
  expiresAt: string;
  maxBytes: number;
  mimeType: string;
};

export type UploadResult = {
  asset: StorageAsset;
};

export type DownloadResult = {
  url: string;
  expiresAt: string | null;
  visibility: StorageVisibility;
};

export type CreateUploadIntentInput = {
  purpose: StoragePurpose;
  visibility: StorageVisibility;
  mimeType: string;
  fileSize: number;
  ownerType?: string | null;
  ownerId?: string | null;
  checksum?: string | null;
};

export type MediaAssetRow = {
  id: string;
  businessId: string;
  storageKey: string;
  bucket: string;
  purpose: string;
  visibility: string;
  mimeType: string;
  fileSize: number;
  etag: string | null;
  checksum: string | null;
  ownerType: string | null;
  ownerId: string | null;
  status: string;
  uploadedBy: string | null;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
  isDeleted: boolean;
};
