import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { createLocalFilesystemProvider } from './local-filesystem-provider';
import { RailwayS3Provider } from './railway-s3-provider';
import type { StorageProvider } from './storage-provider';

/**
 * Resolves the active storage provider.
 * Uses S3 when configured; falls back to local filesystem in development.
 */
export function resolveStorageProvider(
  config: AppConfig,
): StorageProvider | null {
  if (config.storageConfigured) {
    return createStorageProvider(config);
  }
  if (config.environment === 'development') {
    return createLocalFilesystemProvider(config);
  }
  return null;
}

/**
 * Selects the object storage provider from configuration.
 * Credentials are validated at startup via loadAppConfig — no silent fallback.
 */
export function createStorageProvider(config: AppConfig): StorageProvider {
  if (!config.storageConfigured) {
    throw new AppError(
      'STORAGE_NOT_CONFIGURED',
      'Object storage is not configured. Set S3_ENDPOINT, S3_BUCKET, S3_ACCESS_KEY_ID, and S3_SECRET_ACCESS_KEY.',
      503,
    );
  }

  const {
    s3Endpoint,
    s3Bucket,
    s3Region,
    s3AccessKeyId,
    s3SecretAccessKey,
    s3ForcePathStyle,
    s3Ssl,
  } = config;

  if (!s3Endpoint || !s3Bucket || !s3AccessKeyId || !s3SecretAccessKey) {
    throw new AppError(
      'STORAGE_CONFIG_INVALID',
      'Object storage credentials are incomplete',
      500,
    );
  }

  return new RailwayS3Provider({
    endpoint: s3Endpoint,
    bucket: s3Bucket,
    region: s3Region,
    accessKeyId: s3AccessKeyId,
    secretAccessKey: s3SecretAccessKey,
    forcePathStyle: s3ForcePathStyle,
    ssl: s3Ssl,
  });
}
