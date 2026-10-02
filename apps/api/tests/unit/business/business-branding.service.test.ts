import { describe, expect, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import type { BusinessRepository } from '../../../src/modules/business/business.repository';
import { BusinessBrandingService } from '../../../src/modules/business/business-branding.service';
import { StorageNotFoundError } from '../../../src/modules/storage/storage.errors';
import type { StorageService } from '../../../src/modules/storage/storage.service';
import type { UploadIntent } from '../../../src/modules/storage/storage.types';
import { AppError } from '../../../src/shared/errors/app-error';

function baseConfig(): AppConfig {
  return {
    appName: 'test',
    version: '0.0.0',
    host: '0.0.0.0',
    port: 3000,
    apiPrefix: '/api/v1',
    environment: 'test',
    logLevel: 'silent',
    enableDevLogin: true,
    corsOrigins: [],
    websiteUrl: 'https://billingbaba.com',
    invitationExpiryDays: 7,
    notificationProvider: 'console',
    invoiceShareExpiryDays: 90,
    notificationIdempotencyTtlHours: 24,
    storageConfigured: true,
    s3Endpoint: 'https://s3.example.com',
    s3Bucket: 'billing-baba',
    s3Region: 'auto',
    s3AccessKeyId: 'key',
    s3SecretAccessKey: 'secret',
    s3ForcePathStyle: true,
    s3Ssl: true,
    s3PublicBaseUrl: 'https://cdn.example.com',
    storageMaxFileBytes: 10_485_760,
    storageUploadUrlTtlSeconds: 900,
    storageDownloadUrlTtlSeconds: 3600,
  };
}

describe('BusinessBrandingService', () => {
  test('rejects staff role for branding writes', () => {
    const service = new BusinessBrandingService({
      config: baseConfig(),
      repository: {} as BusinessRepository,
      storage: {} as StorageService,
    });

    expect(() => service.assertCanWriteBranding('staff')).toThrow(AppError);
  });

  test('allows owner role for branding writes', () => {
    const service = new BusinessBrandingService({
      config: baseConfig(),
      repository: {} as BusinessRepository,
      storage: {} as StorageService,
    });

    expect(() => service.assertCanWriteBranding('owner')).not.toThrow();
  });

  test('completeBrandingUpload binds asset and deletes previous', async () => {
    const businessId = 'biz-1';
    const accountId = 'acc-1';
    let deletedOld = false;

    const storage = {
      completeUpload: async () => ({
        id: 'asset-new',
        businessId,
        storageKey: 'key',
        bucket: 'b',
        purpose: 'branding',
        visibility: 'authenticated',
        mimeType: 'image/png',
        fileSize: 100,
        etag: 'e',
        checksum: null,
        ownerType: 'logo',
        ownerId: businessId,
        status: 'ready',
        uploadedBy: accountId,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }),
      resolveBusinessAssetUrl: async () => 'https://cdn/logo.png',
      deleteAsset: async (_b: string, _a: string, assetId: string) => {
        if (assetId === 'asset-old') deletedOld = true;
      },
    } as unknown as StorageService;

    const repository = {
      getBrandingMediaAssetId: async () => 'asset-old',
      bindBrandingAsset: async () => undefined,
    } as unknown as BusinessRepository;

    const service = new BusinessBrandingService({
      config: baseConfig(),
      repository,
      storage,
    });

    const result = await service.completeBrandingUpload(
      businessId,
      accountId,
      'logo',
      'intent-1',
    );

    expect(result.media_asset_id).toBe('asset-new');
    expect(result.url).toBe('https://cdn/logo.png');
    expect(deletedOld).toBe(true);
  });

  test('deleteBranding clears binding and deletes storage object', async () => {
    let cleared = false;
    let deleted = false;

    const repository = {
      getBrandingMediaAssetId: async () => 'asset-1',
      clearBrandingAsset: async () => {
        cleared = true;
      },
    } as unknown as BusinessRepository;

    const storage = {
      deleteAsset: async () => {
        deleted = true;
      },
    } as unknown as StorageService;

    const service = new BusinessBrandingService({
      config: baseConfig(),
      repository,
      storage,
    });

    await service.deleteBranding('biz-1', 'acc-1', 'signature');
    expect(cleared).toBe(true);
    expect(deleted).toBe(true);
  });

  test('deleteBranding throws when asset missing', async () => {
    const repository = {
      getBrandingMediaAssetId: async () => null,
    } as unknown as BusinessRepository;

    const service = new BusinessBrandingService({
      config: baseConfig(),
      repository,
      storage: {} as StorageService,
    });

    await expect(
      service.deleteBranding('biz-1', 'acc-1', 'logo'),
    ).rejects.toThrow(AppError);
  });

  test('createBrandingUploadIntent delegates to storage with policy', async () => {
    let capturedPolicyMax = 0;
    const storage = {
      createUploadIntent: async (
        _b: string,
        _a: string,
        input: { ownerType?: string | null },
        policy?: { maxBytes: number },
      ): Promise<UploadIntent> => {
        capturedPolicyMax = policy?.maxBytes ?? 0;
        expect(input.ownerType).toBe('logo');
        return {
          intentId: 'intent-1',
          uploadUrl: 'https://upload',
          storageKey: 'key',
          headers: {},
          expiresAt: new Date().toISOString(),
          maxBytes: policy?.maxBytes ?? 0,
          mimeType: 'image/png',
        };
      },
    } as unknown as StorageService;

    const service = new BusinessBrandingService({
      config: baseConfig(),
      repository: {} as BusinessRepository,
      storage,
    });

    const intent = await service.createBrandingUploadIntent(
      'biz-1',
      'acc-1',
      'logo',
      'image/png',
      1024,
    );

    expect(intent.intentId).toBe('intent-1');
    expect(capturedPolicyMax).toBe(2 * 1024 * 1024);
  });

  test('completeBrandingUpload rejects mismatched intent kind', async () => {
    const storage = {
      completeUpload: async () => ({
        id: 'asset-new',
        businessId: 'biz-1',
        storageKey: 'key',
        bucket: 'b',
        purpose: 'branding',
        visibility: 'authenticated',
        mimeType: 'image/png',
        fileSize: 100,
        etag: 'e',
        checksum: null,
        ownerType: 'signature',
        ownerId: 'biz-1',
        status: 'ready',
        uploadedBy: 'acc-1',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }),
    } as unknown as StorageService;

    const service = new BusinessBrandingService({
      config: baseConfig(),
      repository: {} as BusinessRepository,
      storage,
    });

    await expect(
      service.completeBrandingUpload('biz-1', 'acc-1', 'logo', 'intent-1'),
    ).rejects.toThrow(AppError);
  });

  test('deleteBranding ignores missing storage object', async () => {
    const repository = {
      getBrandingMediaAssetId: async () => 'asset-1',
      clearBrandingAsset: async () => undefined,
    } as unknown as BusinessRepository;

    const storage = {
      deleteAsset: async () => {
        throw new StorageNotFoundError();
      },
    } as unknown as StorageService;

    const service = new BusinessBrandingService({
      config: baseConfig(),
      repository,
      storage,
    });

    await expect(
      service.deleteBranding('biz-1', 'acc-1', 'stamp'),
    ).resolves.toBeUndefined();
  });
});
