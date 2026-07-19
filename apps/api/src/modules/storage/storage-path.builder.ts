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

  if (ownerType) {
    segments.push(ownerType);
    if (ownerId) {
      segments.push(ownerId);
    }
  }

  segments.push(`${assetId}.${ext}`);
  return segments.join('/');
}

export type BuildAccountStoragePathParams = {
  environment: AppConfig['environment'];
  accountId: string;
  assetId: string;
  mimeType: string;
};

/**
 * Account-scoped storage keys (avatars).
 * Format: {env}/accounts/{accountId}/avatar/{assetId}.{ext}
 */
export function buildAccountStoragePath(
  params: BuildAccountStoragePathParams,
): string {
  const { environment, accountId, assetId, mimeType } = params;
  const ext = extensionForMimeType(mimeType);
  return [environment, 'accounts', accountId, 'avatar', `${assetId}.${ext}`].join(
    '/',
  );
}
