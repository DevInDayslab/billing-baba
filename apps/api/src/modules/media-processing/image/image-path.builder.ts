import type { AppConfig } from '../../../config/app_config';
import {
  PURPOSE_PATH_SEGMENTS,
  type StoragePurpose,
} from '../../storage/storage.constants';
import {
  extensionForFormat,
  type ImageVariant,
  type OutputImageFormat,
  variantFileSuffix,
} from './image.constants';

export type BuildStagingPathParams = {
  environment: AppConfig['environment'];
  businessId: string | null;
  accountId?: string;
  assetId: string;
  extension: string;
};

/** Staging key before optimization: .../staging/{assetId}.{ext} */
export function buildStagingStoragePath(params: BuildStagingPathParams): string {
  const { environment, businessId, accountId, assetId, extension } = params;

  if (businessId) {
    return [
      environment,
      'businesses',
      businessId,
      'staging',
      `${assetId}.${extension}`,
    ].join('/');
  }

  if (!accountId) {
    throw new Error('accountId required for account-scoped staging path');
  }

  return [
    environment,
    'accounts',
    accountId,
    'staging',
    `${assetId}.${extension}`,
  ].join('/');
}

export type BuildProcessedImagePathParams = {
  environment: AppConfig['environment'];
  businessId: string | null;
  accountId?: string;
  purpose: StoragePurpose;
  assetId: string;
  variant: ImageVariant;
  format: OutputImageFormat;
  ownerType?: string | null;
  ownerId?: string | null;
};

/**
 * Canonical processed image keys: .../{purposeDir}/[{owner}/]{assetId}-{suffix}.{ext}
 */
export function buildProcessedImagePath(
  params: BuildProcessedImagePathParams,
): string {
  const {
    environment,
    businessId,
    accountId,
    purpose,
    assetId,
    variant,
    format,
    ownerType,
    ownerId,
  } = params;

  const ext = extensionForFormat(format);
  const suffix = variantFileSuffix(variant);
  const filename = `${assetId}-${suffix}.${ext}`;

  if (businessId) {
    const purposeDir = PURPOSE_PATH_SEGMENTS[purpose];
    const segments = [environment, 'businesses', businessId, purposeDir];
    if (ownerType) {
      segments.push(ownerType);
      if (ownerId) segments.push(ownerId);
    }
    segments.push(filename);
    return segments.join('/');
  }

  if (!accountId) {
    throw new Error('accountId required for account-scoped processed path');
  }

  return [environment, 'accounts', accountId, 'avatar', filename].join('/');
}
