import { describe, expect, mock, test } from 'bun:test';
import sharp from 'sharp';
import type { AppConfig } from '../../../src/config/app_config';
import { ImageService } from '../../../src/modules/images/image.service';
import type { ImageVariantRepository } from '../../../src/modules/images/image.repository';
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
  test('processSourceAsset stores all variants and returns download URLs', async () => {
    const sourceBuffer = await sharp({
      create: {
        width: 1200,
        height: 900,
        channels: 3,
        background: { r: 255, g: 0, b: 0 },
      },
    })
      .jpeg()
      .toBuffer();

    const storedAssetIds: string[] = [];
    let storeCount = 0;

    const storage = {
      getAsset: mock(async () => sourceAsset),
      getObjectBuffer: mock(async () => sourceBuffer),
      storeDerivativeFromBuffer: mock(async () => {
        storeCount += 1;
        const id = `variant-asset-${storeCount}`;
        storedAssetIds.push(id);
        return {
          ...sourceAsset,
          id,
          mimeType: 'image/webp',
          purpose: 'derivatives',
        };
      }),
      replaceObjectBuffer: mock(async () => sourceAsset),
      getDownloadUrl: mock(async () => ({
        url: `https://cdn.example.com/${storeCount}.webp`,
        expiresAt: new Date().toISOString(),
        visibility: 'authenticated' as const,
      })),
      resolvePublicCdnUrl: mock((key: string) => `https://cdn.example.com/${key}`),
    } as unknown as StorageService;

    const repository = {
      findBySourceAndVariant: mock(async () => null),
      upsertVariant: mock(async (values) => ({
        id: `row-${values.variant}`,
        businessId,
        sourceMediaAssetId: sourceAssetId,
        variant: values.variant,
        mediaAssetId: values.mediaAssetId,
        width: values.width,
        height: values.height,
        fileSize: values.fileSize,
        mimeType: values.mimeType,
        storageKey: `derivatives/${values.variant}.webp`,
        createdAt: new Date(),
        updatedAt: new Date(),
      })),
      listBySource: mock(async () => []),
    } as unknown as ImageVariantRepository;

    const service = new ImageService({
      config: baseConfig(),
      storage,
      repository,
    });

    const result = await service.processSourceAsset(
      businessId,
      accountId,
      sourceAssetId,
    );

    expect(result.source_media_asset_id).toBe(sourceAssetId);
    expect(result.variants).toHaveLength(4);
    expect(storage.storeDerivativeFromBuffer).toHaveBeenCalledTimes(4);
    expect(result.variants.every((item) => item.mime_type === 'image/webp')).toBe(
      true,
    );
    expect(result.variants[0]?.cdn_url).toContain('https://cdn.example.com/');
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
        findBySourceAndVariant: async () => null,
        upsertVariant: async () => {
          throw new Error('should not run');
        },
        listBySource: async () => [],
      } as unknown as ImageVariantRepository,
    });

    await expect(
      service.processSourceAsset(businessId, accountId, sourceAssetId),
    ).rejects.toMatchObject({ code: 'VALIDATION_ERROR' });
  });
});
