import type { AppConfig } from '../../config/app_config';
import {
  type AllowedStorageMimeType,
  MIME_TO_EXTENSION,
  PURPOSE_PATH_SEGMENTS,
  type StoragePurpose,
} from './storage.constants';
import { StorageValidationError } from './storage.errors';

export type BuildStoragePathParams = {
  environment: AppConfig['environment'];
  businessId: string;
  purpose: StoragePurpose;
  assetId: string;
  mimeType: string;
  ownerType?: string | null;
  ownerId?: string | null;
};

export function extensionForMimeType(mimeType: string): string {
  const ext = MIME_TO_EXTENSION[mimeType as AllowedStorageMimeType];
  if (!ext) {
    throw new StorageValidationError(`Unsupported MIME type: ${mimeType}`, {
      mime_type: ['MIME type is not allowed'],
    });
  }
  return ext;
}

/**
 * Central storage key builder.
 * Format: {env}/businesses/{businessId}/{purposeDir}/[{ownerType}/{ownerId}/]{assetId}.{ext}
 */
export function buildStoragePath(params: BuildStoragePathParams): string {
  const {
    environment,
    businessId,
    purpose,
    assetId,
    mimeType,
    ownerType,
    ownerId,
  } = params;

  const ext = extensionForMimeType(mimeType);
  const purposeDir = PURPOSE_PATH_SEGMENTS[purpose];
  const segments = [environment, 'businesses', businessId, purposeDir];

  if (ownerType && ownerId) {
    segments.push(ownerType, ownerId);
  }

  segments.push(`${assetId}.${ext}`);
  return segments.join('/');
}
