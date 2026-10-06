import { describe, expect, mock, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import type { ImageVariantRepository } from '../../../src/modules/images/image.repository';
import { ImageService } from '../../../src/modules/images/image.service';
import type { MediaProcessingService } from '../../../src/modules/media-processing/media-processing.service';
import type { StorageService } from '../../../src/modules/storage/storage.service';
import type { StorageAsset } from '../../../src/modules/storage/storage.types';

const businessId = '11111111-1111-1111-1111-111111111111';
const accountId = '22222222-2222-2222-2222-222222222222';
const sourceAssetId = '33333333-3333-3333-3333-333333333333';

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

const sourceAsset: StorageAsset = {
  id: sourceAssetId,
  businessId,
  storageKey: 'test/businesses/source.jpg',
  bucket: 'billing-baba',
  purpose: 'items',
  visibility: 'authenticated',
  mimeType: 'image/jpeg',
  fileSize: 1200,
  etag: 'etag',
  checksum: null,
  ownerType: 'item',
  ownerId: '44444444-4444-4444-4444-444444444444',
  status: 'ready',
  uploadedBy: accountId,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
};

describe('ImageService', () => {
  test('processSourceAsset delegates to MediaProcessingService and returns variants', async () => {
    const processAsset = mock(async () => undefined);

    const storage = {
      getAsset: mock(async () => sourceAsset),
      getDownloadUrl: mock(async () => ({
        url: 'https://cdn.example.com/thumb.webp',
        expiresAt: new Date().toISOString(),
        visibility: 'authenticated' as const,
      })),
      resolvePublicCdnUrl: mock(
        (key: string) => `https://cdn.example.com/${key}`,
      ),
    } as unknown as StorageService;

    const repository = {
      listBySource: mock(async () => [
        {
          id: 'row-thumbnail',
          businessId,
          sourceMediaAssetId: sourceAssetId,
          variant: 'thumbnail',
          mediaAssetId: '77777777-7777-7777-7777-777777777777',
          width: 256,
          height: 192,
          fileSize: 900,
          mimeType: 'image/webp',
          storageKey: 'items/asset-thumb.webp',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ]),
    } as unknown as ImageVariantRepository;

    const mediaProcessing = {
      processAsset,
      deleteVariantsForSource: mock(async () => undefined),
    } as unknown as MediaProcessingService;

    const service = new ImageService({
      config: baseConfig(),
      storage,
      repository,
      mediaProcessing,
    });

    const result = await service.processSourceAsset(
      businessId,
      accountId,
      sourceAssetId,
    );

    expect(processAsset).toHaveBeenCalledWith(
      businessId,
      accountId,
      sourceAssetId,
    );
    expect(result.source_media_asset_id).toBe(sourceAssetId);
    expect(result.variants).toHaveLength(1);
    expect(result.variants[0]?.variant).toBe('thumbnail');
  });

  test('processSourceAsset rejects non-image sources', async () => {
    const storage = {
      getAsset: mock(async () => ({
        ...sourceAsset,
        mimeType: 'application/pdf',
      })),
    } as unknown as StorageService;

    const service = new ImageService({
      config: baseConfig(),
      storage,
      repository: {
        listBySource: async () => [],
      } as unknown as ImageVariantRepository,
      mediaProcessing: {
        processAsset: async () => undefined,
        deleteVariantsForSource: async () => undefined,
      } as unknown as MediaProcessingService,
    });

    await expect(
      service.processSourceAsset(businessId, accountId, sourceAssetId),
    ).rejects.toMatchObject({ code: 'VALIDATION_ERROR' });
  });

  test('deleteVariantsForSource delegates to MediaProcessingService', async () => {
    const deleteVariantsForSource = mock(async () => undefined);

    const service = new ImageService({
      config: baseConfig(),
      storage: {} as StorageService,
      repository: {} as ImageVariantRepository,
      mediaProcessing: {
        processAsset: async () => undefined,
        deleteVariantsForSource,
      } as unknown as MediaProcessingService,
    });

    await service.deleteVariantsForSource(businessId, accountId, sourceAssetId);

    expect(deleteVariantsForSource).toHaveBeenCalledWith(
      businessId,
      accountId,
      sourceAssetId,
    );
  });
});
