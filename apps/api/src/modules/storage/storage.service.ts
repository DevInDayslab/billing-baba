import { randomUUID } from 'node:crypto';
import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import type { StorageProvider } from '../../providers/storage';
import { createStorageProvider } from '../../providers/storage';
import { AppError } from '../../shared/errors/app-error';
import {
  ALLOWED_STORAGE_MIME_TYPES,
  type AllowedStorageMimeType,
} from './storage.constants';
import {
  StorageConfigurationError,
  StorageNotFoundError,
  StoragePermissionError,
  StorageUploadFailedError,
  StorageValidationError,
} from './storage.errors';
import { toStorageAsset } from './storage.mapper';
import { MediaAssetRepository } from './storage.repository';
import type {
  CreateUploadIntentInput,
  DownloadResult,
  StorageAsset,
  StorageValidationPolicy,
  UploadIntent,
} from './storage.types';
import {
  buildAccountStoragePath,
  buildStoragePath,
} from './storage-path.builder';

export type StorageServiceDeps = {
  config: AppConfig;
  repository?: MediaAssetRepository;
  provider?: StorageProvider;
  logger?: {
    info: (obj: object, msg?: string) => void;
    warn: (obj: object, msg?: string) => void;
    error: (obj: object, msg?: string) => void;
  };
};

type Logger = NonNullable<StorageServiceDeps['logger']>;

const noopLogger: Logger = {
  info: () => undefined,
  warn: () => undefined,
  error: () => undefined,
};

export class StorageService {
  private readonly config: AppConfig;
  private readonly repository: MediaAssetRepository;
  private readonly provider: StorageProvider | null;
  private readonly log: Logger;

  constructor(deps: StorageServiceDeps) {
    this.config = deps.config;
    this.log = deps.logger ?? noopLogger;

    if (deps.repository) {
      this.repository = deps.repository;
    } else {
      const db = getDb();
      if (!db) {
        throw new AppError(
          'DATABASE_NOT_CONFIGURED',
          'Database is not configured',
          503,
        );
      }
      this.repository = new MediaAssetRepository(db);
    }

    if (deps.provider) {
      this.provider = deps.provider;
    } else if (deps.config.storageConfigured) {
      this.provider = createStorageProvider(deps.config);
    } else {
      this.provider = null;
    }
  }

  private requireProvider(): StorageProvider {
    if (!this.provider) {
      throw new StorageConfigurationError(
        'Object storage is not configured. Set S3_ENDPOINT, S3_BUCKET, S3_ACCESS_KEY_ID, and S3_SECRET_ACCESS_KEY.',
      );
    }
    return this.provider;
  }

  private async assertBusinessAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.repository.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!hasAccess) {
      throw new StoragePermissionError(
        'You do not have access to this business',
      );
    }
  }

  private validateMimeAndSize(
    mimeType: string,
    fileSize: number,
    policy?: StorageValidationPolicy,
  ): void {
    const allowedMimes = policy?.allowedMimes ?? ALLOWED_STORAGE_MIME_TYPES;
    const maxBytes = policy?.maxBytes ?? this.config.storageMaxFileBytes;

    if (!allowedMimes.includes(mimeType)) {
      throw new StorageValidationError(
        `Unsupported MIME type: ${mimeType}. Allowed: ${allowedMimes.join(', ')}`,
        { mime_type: ['MIME type is not allowed'] },
      );
    }

    if (!Number.isFinite(fileSize) || fileSize <= 0) {
      throw new StorageValidationError('file_size must be a positive number', {
        file_size: ['Must be greater than 0'],
      });
    }

    if (fileSize > maxBytes) {
      throw new StorageValidationError(
        `File size exceeds the ${maxBytes} byte limit`,
        { file_size: ['File too large'] },
      );
    }
  }

  async createUploadIntent(
    businessId: string,
    accountId: string,
    input: CreateUploadIntentInput,
    policy?: StorageValidationPolicy,
  ): Promise<UploadIntent> {
    await this.assertBusinessAccess(businessId, accountId);
    this.validateMimeAndSize(input.mimeType, input.fileSize, policy);

    const provider = this.requireProvider();
    const assetId = randomUUID();
    const storageKey = buildStoragePath({
      environment: this.config.environment,
      businessId,
      purpose: input.purpose,
      assetId,
      mimeType: input.mimeType,
      ownerType: input.ownerType,
      ownerId: input.ownerId,
    });

    await this.repository.insert({
      id: assetId,
      businessId,
      storageKey,
      bucket: provider.bucket,
      purpose: input.purpose,
      visibility: input.visibility,
      mimeType: input.mimeType,
      fileSize: input.fileSize,
      checksum: input.checksum ?? null,
      ownerType: input.ownerType ?? null,
      ownerId: input.ownerId ?? null,
      status: 'pending',
      uploadedBy: accountId,
    });

    const upload = await provider.createUploadUrl({
      key: storageKey,
      mimeType: input.mimeType,
      expiresInSeconds: this.config.storageUploadUrlTtlSeconds,
      contentLength: input.fileSize,
    });

    this.log.info(
      {
        event: 'storage.upload_intent',
        businessId,
        intentId: assetId,
        purpose: input.purpose,
        visibility: input.visibility,
        mimeType: input.mimeType,
        fileSize: input.fileSize,
        storageKey,
      },
      'Storage upload intent created',
    );

    return {
      intentId: assetId,
      uploadUrl: upload.url,
      storageKey,
      headers: upload.headers,
      expiresAt: upload.expiresAt.toISOString(),
      maxBytes: policy?.maxBytes ?? this.config.storageMaxFileBytes,
      mimeType: input.mimeType,
    };
  }

  async completeUpload(
    businessId: string,
    accountId: string,
    intentId: string,
  ): Promise<StorageAsset> {
    await this.assertBusinessAccess(businessId, accountId);
    const provider = this.requireProvider();

    const pending = await this.repository.findById(businessId, intentId);
    if (!pending || pending.status !== 'pending') {
      throw new StorageNotFoundError(
        'Upload intent not found or already completed',
      );
    }

    let head: Awaited<ReturnType<StorageProvider['head']>>;
    try {
      head = await provider.head(pending.storageKey);
    } catch (error) {
      this.log.error(
        {
          event: 'storage.upload_complete_failed',
          businessId,
          intentId,
          storageKey: pending.storageKey,
          error: error instanceof Error ? error.message : 'unknown',
        },
        'Storage HEAD failed during upload complete',
      );
      throw new StorageUploadFailedError(
        'Failed to verify uploaded object',
        502,
      );
    }

    if (!head.exists) {
      throw new StorageUploadFailedError(
        'Uploaded object was not found in storage. Complete the PUT to the upload URL first.',
      );
    }

    if (
      head.contentType &&
      normalizeMime(head.contentType) !== normalizeMime(pending.mimeType)
    ) {
      throw new StorageUploadFailedError(
        `Uploaded Content-Type (${head.contentType}) does not match declared MIME type (${pending.mimeType})`,
      );
    }

    if (
      head.contentLength !== undefined &&
      head.contentLength > this.config.storageMaxFileBytes
    ) {
      throw new StorageUploadFailedError(
        `Uploaded object exceeds the ${this.config.storageMaxFileBytes} byte limit`,
      );
    }

    // Allow small variance only when ContentLength is present; prefer declared size if missing.
    const verifiedSize = head.contentLength ?? pending.fileSize;

    const ready = await this.repository.markReady(businessId, intentId, {
      etag: head.etag ?? null,
      fileSize: verifiedSize,
      mimeType: head.contentType
        ? normalizeMime(head.contentType)
        : pending.mimeType,
    });

    if (!ready) {
      throw new StorageNotFoundError(
        'Upload intent not found or already completed',
      );
    }

    this.log.info(
      {
        event: 'storage.upload_complete',
        businessId,
        intentId,
        storageKey: pending.storageKey,
        fileSize: verifiedSize,
        etag: head.etag ?? null,
      },
      'Storage upload completed',
    );

    return toStorageAsset(ready);
  }

  async getAsset(
    businessId: string,
    accountId: string,
    assetId: string,
  ): Promise<StorageAsset> {
    await this.assertBusinessAccess(businessId, accountId);
    const row = await this.repository.findById(businessId, assetId);
    if (!row || row.status !== 'ready') {
      throw new StorageNotFoundError();
    }
    return toStorageAsset(row);
  }

  async getDownloadUrl(
    businessId: string,
    accountId: string,
    assetId: string,
  ): Promise<DownloadResult> {
    await this.assertBusinessAccess(businessId, accountId);
    const provider = this.requireProvider();

    const row = await this.repository.findById(businessId, assetId);
    if (!row || row.status !== 'ready') {
      throw new StorageNotFoundError();
    }

    if (row.visibility === 'public') {
      const url = this.buildPublicUrl(row.storageKey);
      return {
        url,
        expiresAt: null,
        visibility: 'public',
      };
    }

    const download = await provider.createDownloadUrl({
      key: row.storageKey,
      expiresInSeconds: this.config.storageDownloadUrlTtlSeconds,
    });

    return {
      url: download.url,
      expiresAt: download.expiresAt.toISOString(),
      visibility: row.visibility as StorageAsset['visibility'],
    };
  }

  /**
   * Signed download URL without membership check — only for token-gated public flows
   * where the caller has already validated access.
   */
  async getBusinessAssetDownloadUrl(
    businessId: string,
    assetId: string,
  ): Promise<DownloadResult> {
    const provider = this.requireProvider();

    const row = await this.repository.findById(businessId, assetId);
    if (!row || row.status !== 'ready') {
      throw new StorageNotFoundError();
    }

    if (row.visibility === 'public') {
      return {
        url: this.buildPublicUrl(row.storageKey),
        expiresAt: null,
        visibility: 'public',
      };
    }

    const download = await provider.createDownloadUrl({
      key: row.storageKey,
      expiresInSeconds: this.config.storageDownloadUrlTtlSeconds,
    });

    return {
      url: download.url,
      expiresAt: download.expiresAt.toISOString(),
      visibility: row.visibility as StorageAsset['visibility'],
    };
  }

  async deleteAsset(
    businessId: string,
    accountId: string,
    assetId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    const provider = this.requireProvider();

    const deleted = await this.repository.softDelete(businessId, assetId);
    if (!deleted) {
      throw new StorageNotFoundError();
    }

    try {
      await provider.delete(deleted.storageKey);
    } catch (error) {
      this.log.warn(
        {
          event: 'storage.delete_object_failed',
          businessId,
          assetId,
          storageKey: deleted.storageKey,
          error: error instanceof Error ? error.message : 'unknown',
        },
        'Failed to delete object from storage provider (row soft-deleted)',
      );
    }

    this.log.info(
      {
        event: 'storage.delete',
        businessId,
        assetId,
        storageKey: deleted.storageKey,
      },
      'Storage asset deleted',
    );
  }

  /**
   * Soft-delete an existing ready asset and create a new upload intent
   * for the same purpose/owner. Service-only (no HTTP route in Phase 1).
   */
  async replaceAsset(
    businessId: string,
    accountId: string,
    assetId: string,
    input: {
      mimeType: string;
      fileSize: number;
      checksum?: string | null;
      visibility?: CreateUploadIntentInput['visibility'];
    },
  ): Promise<UploadIntent> {
    await this.assertBusinessAccess(businessId, accountId);

    const existing = await this.repository.findById(businessId, assetId);
    if (!existing || existing.status !== 'ready') {
      throw new StorageNotFoundError();
    }

    await this.deleteAsset(businessId, accountId, assetId);

    this.log.info(
      {
        event: 'storage.replace',
        businessId,
        replacedAssetId: assetId,
        purpose: existing.purpose,
      },
      'Storage asset replace started',
    );

    return this.createUploadIntent(businessId, accountId, {
      purpose: existing.purpose as CreateUploadIntentInput['purpose'],
      visibility:
        input.visibility ??
        (existing.visibility as CreateUploadIntentInput['visibility']),
      mimeType: input.mimeType,
      fileSize: input.fileSize,
      ownerType: existing.ownerType,
      ownerId: existing.ownerId,
      checksum: input.checksum,
    });
  }

  async createAccountUploadIntent(
    accountId: string,
    input: {
      mimeType: string;
      fileSize: number;
      checksum?: string | null;
    },
    policy: StorageValidationPolicy,
  ): Promise<UploadIntent> {
    this.validateMimeAndSize(input.mimeType, input.fileSize, policy);

    const provider = this.requireProvider();
    const assetId = randomUUID();
    const storageKey = buildAccountStoragePath({
      environment: this.config.environment,
      accountId,
      assetId,
      mimeType: input.mimeType,
    });

    await this.repository.insert({
      id: assetId,
      businessId: null,
      storageKey,
      bucket: provider.bucket,
      purpose: 'branding',
      visibility: 'authenticated',
      mimeType: input.mimeType,
      fileSize: input.fileSize,
      checksum: input.checksum ?? null,
      ownerType: 'avatar',
      ownerId: accountId,
      status: 'pending',
      uploadedBy: accountId,
    });

    const upload = await provider.createUploadUrl({
      key: storageKey,
      mimeType: input.mimeType,
      expiresInSeconds: this.config.storageUploadUrlTtlSeconds,
      contentLength: input.fileSize,
    });

    this.log.info(
      {
        event: 'storage.account_upload_intent',
        accountId,
        intentId: assetId,
        mimeType: input.mimeType,
        fileSize: input.fileSize,
        storageKey,
      },
      'Account avatar upload intent created',
    );

    return {
      intentId: assetId,
      uploadUrl: upload.url,
      storageKey,
      headers: upload.headers,
      expiresAt: upload.expiresAt.toISOString(),
      maxBytes: policy.maxBytes,
      mimeType: input.mimeType,
    };
  }

  async completeAccountUpload(
    accountId: string,
    intentId: string,
  ): Promise<StorageAsset> {
    const provider = this.requireProvider();

    const pending = await this.repository.findByIdForAccount(accountId, intentId);
    if (!pending || pending.status !== 'pending') {
      throw new StorageNotFoundError(
        'Upload intent not found or already completed',
      );
    }

    let head: Awaited<ReturnType<StorageProvider['head']>>;
    try {
      head = await provider.head(pending.storageKey);
    } catch (error) {
      this.log.error(
        {
          event: 'storage.account_upload_complete_failed',
          accountId,
          intentId,
          storageKey: pending.storageKey,
          error: error instanceof Error ? error.message : 'unknown',
        },
        'Storage HEAD failed during account upload complete',
      );
      throw new StorageUploadFailedError(
        'Failed to verify uploaded object',
        502,
      );
    }

    if (!head.exists) {
      throw new StorageUploadFailedError(
        'Uploaded object was not found in storage. Complete the PUT to the upload URL first.',
      );
    }

    if (
      head.contentType &&
      normalizeMime(head.contentType) !== normalizeMime(pending.mimeType)
    ) {
      throw new StorageUploadFailedError(
        `Uploaded Content-Type (${head.contentType}) does not match declared MIME type (${pending.mimeType})`,
      );
    }

    const verifiedSize = head.contentLength ?? pending.fileSize;

    const ready = await this.repository.markReadyForAccount(accountId, intentId, {
      etag: head.etag ?? null,
      fileSize: verifiedSize,
      mimeType: head.contentType
        ? normalizeMime(head.contentType)
        : pending.mimeType,
    });

    if (!ready) {
      throw new StorageNotFoundError(
        'Upload intent not found or already completed',
      );
    }

    this.log.info(
      {
        event: 'storage.account_upload_complete',
        accountId,
        intentId,
        storageKey: pending.storageKey,
        fileSize: verifiedSize,
      },
      'Account avatar upload completed',
    );

    return toStorageAsset(ready);
  }

  async getAccountDownloadUrl(
    accountId: string,
    assetId: string,
  ): Promise<DownloadResult> {
    const provider = this.requireProvider();

    const row = await this.repository.findByIdForAccount(accountId, assetId);
    if (!row || row.status !== 'ready') {
      throw new StorageNotFoundError();
    }

    const download = await provider.createDownloadUrl({
      key: row.storageKey,
      expiresInSeconds: this.config.storageDownloadUrlTtlSeconds,
    });

    return {
      url: download.url,
      expiresAt: download.expiresAt.toISOString(),
      visibility: row.visibility as StorageAsset['visibility'],
    };
  }

  async deleteAccountAsset(accountId: string, assetId: string): Promise<void> {
    const provider = this.requireProvider();

    const deleted = await this.repository.softDeleteForAccount(accountId, assetId);
    if (!deleted) {
      throw new StorageNotFoundError();
    }

    try {
      await provider.delete(deleted.storageKey);
    } catch (error) {
      this.log.warn(
        {
          event: 'storage.account_delete_object_failed',
          accountId,
          assetId,
          storageKey: deleted.storageKey,
          error: error instanceof Error ? error.message : 'unknown',
        },
        'Failed to delete account object from storage provider (row soft-deleted)',
      );
    }

    this.log.info(
      {
        event: 'storage.account_delete',
        accountId,
        assetId,
        storageKey: deleted.storageKey,
      },
      'Account storage asset deleted',
    );
  }

  /** Resolve a download URL for a ready business asset (caller must authorize). */
  async resolveBusinessAssetUrl(
    businessId: string,
    accountId: string,
    assetId: string,
  ): Promise<string> {
    const result = await this.getDownloadUrl(businessId, accountId, assetId);
    return result.url;
  }

  /** Resolve a download URL for a ready account avatar. */
  async resolveAccountAssetUrl(accountId: string, assetId: string): Promise<string> {
    const result = await this.getAccountDownloadUrl(accountId, assetId);
    return result.url;
  }

  /**
   * Server-side upload for generated exports (PDF, CSV, Excel).
   * Inserts a ready media_assets row after PUT to object storage.
   */
  async storeFromBuffer(
    businessId: string,
    accountId: string,
    input: {
      purpose: CreateUploadIntentInput['purpose'];
      visibility: CreateUploadIntentInput['visibility'];
      mimeType: string;
      buffer: Buffer;
      ownerType?: string | null;
      ownerId?: string | null;
      extension?: string;
      policy?: StorageValidationPolicy;
    },
  ): Promise<StorageAsset> {
    await this.assertBusinessAccess(businessId, accountId);
    this.validateMimeAndSize(
      input.mimeType,
      input.buffer.length,
      input.policy,
    );

    const provider = this.requireProvider();
    const assetId = randomUUID();
    const storageKey = buildStoragePath({
      environment: this.config.environment,
      businessId,
      purpose: input.purpose,
      assetId,
      mimeType: input.mimeType,
      ownerType: input.ownerType,
      ownerId: input.ownerId,
      extension: input.extension,
    });

    await this.repository.insert({
      id: assetId,
      businessId,
      storageKey,
      bucket: provider.bucket,
      purpose: input.purpose,
      visibility: input.visibility,
      mimeType: input.mimeType,
      fileSize: input.buffer.length,
      checksum: null,
      ownerType: input.ownerType ?? null,
      ownerId: input.ownerId ?? null,
      status: 'pending',
      uploadedBy: accountId,
    });

    const put = await provider.putObject({
      key: storageKey,
      body: input.buffer,
      mimeType: input.mimeType,
    });

    const ready = await this.repository.markReady(businessId, assetId, {
      etag: put.etag ?? null,
      fileSize: put.contentLength,
      mimeType: input.mimeType,
    });

    if (!ready) {
      throw new StorageNotFoundError('Failed to mark stored object ready');
    }

    this.log.info(
      {
        event: 'storage.store_from_buffer',
        businessId,
        assetId,
        purpose: input.purpose,
        mimeType: input.mimeType,
        fileSize: put.contentLength,
        storageKey,
      },
      'Storage object stored from buffer',
    );

    return toStorageAsset(ready);
  }

  private buildPublicUrl(storageKey: string): string {
    if (this.config.s3PublicBaseUrl) {
      return `${this.config.s3PublicBaseUrl.replace(/\/$/, '')}/${storageKey}`;
    }

    const endpoint = this.config.s3Endpoint?.replace(/\/$/, '') ?? '';
    const bucket = this.config.s3Bucket ?? '';
    const base =
      endpoint.startsWith('http://') || endpoint.startsWith('https://')
        ? endpoint
        : `${this.config.s3Ssl ? 'https' : 'http'}://${endpoint}`;

    if (this.config.s3ForcePathStyle) {
      return `${base}/${bucket}/${storageKey}`;
    }
    const host = base.replace(/^https?:\/\//, '');
    const scheme = this.config.s3Ssl ? 'https' : 'http';
    return `${scheme}://${bucket}.${host}/${storageKey}`;
  }
}

function normalizeMime(value: string): string {
  return value.split(';')[0]?.trim().toLowerCase() ?? value.toLowerCase();
}
