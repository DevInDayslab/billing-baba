import { describe, expect, test } from 'bun:test';
import type { AppConfig } from '../../../src/config/app_config';
import type { ItemRepository } from '../../../src/modules/inventory/item.repository';
import type { ItemLocationRepository } from '../../../src/modules/inventory/item-location.repository';
import { MAX_ITEM_GALLERY_IMAGES } from '../../../src/modules/inventory/item-media.constants';
import { ItemMediaService } from '../../../src/modules/inventory/item-media.service';
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

const sampleImage = {
  id: 'img-1',
  image_url: 'https://cdn/item.png',
  sort_order: 0,
  is_primary: true,
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString(),
};

describe('ItemMediaService', () => {
  test('createItemImageUploadIntent rejects when gallery limit reached', async () => {
    const items = {
      exists: async () => true,
      countImages: async () => MAX_ITEM_GALLERY_IMAGES,
    } as unknown as ItemRepository;

    const service = new ItemMediaService({
      config: baseConfig(),
      itemRepository: items,
      storage: {} as StorageService,
    });

    await expect(
      service.createItemImageUploadIntent(
        'biz-1',
        'acc-1',
        'item-1',
        'image/png',
        1024,
      ),
    ).rejects.toThrow(AppError);
  });

  test('completeItemImageUpload binds asset and replaces previous image', async () => {
    let deletedOld = false;

    const items = {
      exists: async () => true,
      countImages: async () => 1,
      addImage: async () => ({
        ...sampleImage,
        image_url: 'https://cdn/new.png',
      }),
      findImageById: async () => sampleImage,
      getImageMediaAssetId: async () => 'asset-old',
      softDeleteImage: async () => true,
    } as unknown as ItemRepository;

    const storage = {
      completeUpload: async () => ({
        id: 'asset-new',
        businessId: 'biz-1',
        storageKey: 'key',
        bucket: 'b',
        purpose: 'items',
        visibility: 'authenticated',
        mimeType: 'image/png',
        fileSize: 100,
        etag: 'e',
        checksum: null,
        ownerType: 'item',
        ownerId: 'item-1',
        status: 'ready',
        uploadedBy: 'acc-1',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }),
      resolveBusinessAssetUrl: async () => 'https://cdn/new.png',
      deleteAsset: async (_b: string, _a: string, assetId: string) => {
        if (assetId === 'asset-old') deletedOld = true;
      },
    } as unknown as StorageService;

    const service = new ItemMediaService({
      config: baseConfig(),
      itemRepository: items,
      storage,
    });

    const result = await service.completeItemImageUpload(
      'biz-1',
      'acc-1',
      'user-1',
      'item-1',
      'intent-1',
      { replacesImageId: 'img-old' },
    );

    expect(result.media_asset_id).toBe('asset-new');
    expect(result.image_url).toBe('https://cdn/new.png');
    expect(deletedOld).toBe(true);
  });

  test('completeItemImageUpload rejects mismatched intent owner', async () => {
    const items = {
      exists: async () => true,
    } as unknown as ItemRepository;

    const storage = {
      completeUpload: async () => ({
        id: 'asset-new',
        businessId: 'biz-1',
        storageKey: 'key',
        bucket: 'b',
        purpose: 'items',
        visibility: 'authenticated',
        mimeType: 'image/png',
        fileSize: 100,
        etag: 'e',
        checksum: null,
        ownerType: 'rack',
        ownerId: 'loc-1',
        status: 'ready',
        uploadedBy: 'acc-1',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }),
    } as unknown as StorageService;

    const service = new ItemMediaService({
      config: baseConfig(),
      itemRepository: items,
      storage,
    });

    await expect(
      service.completeItemImageUpload(
        'biz-1',
        'acc-1',
        'user-1',
        'item-1',
        'intent-1',
      ),
    ).rejects.toThrow(AppError);
  });

  test('deleteItemImageMedia deletes storage object', async () => {
    let deleted = false;

    const items = {
      exists: async () => true,
      findImageById: async () => sampleImage,
      getImageMediaAssetId: async () => 'asset-1',
      softDeleteImage: async () => true,
    } as unknown as ItemRepository;

    const storage = {
      deleteAsset: async () => {
        deleted = true;
      },
    } as unknown as StorageService;

    const service = new ItemMediaService({
      config: baseConfig(),
      itemRepository: items,
      storage,
    });

    await service.deleteItemImageMedia(
      'biz-1',
      'acc-1',
      'user-1',
      'item-1',
      'img-1',
    );
    expect(deleted).toBe(true);
  });

  test('deleteItemImageMedia ignores missing storage object', async () => {
    const items = {
      exists: async () => true,
      findImageById: async () => sampleImage,
      getImageMediaAssetId: async () => 'asset-1',
      softDeleteImage: async () => true,
    } as unknown as ItemRepository;

    const storage = {
      deleteAsset: async () => {
        throw new StorageNotFoundError();
      },
    } as unknown as StorageService;

    const service = new ItemMediaService({
      config: baseConfig(),
      itemRepository: items,
      storage,
    });

    await expect(
      service.deleteItemImageMedia(
        'biz-1',
        'acc-1',
        'user-1',
        'item-1',
        'img-1',
      ),
    ).resolves.toBeUndefined();
  });

  test('completeRackPhotoUpload replaces previous rack asset', async () => {
    let deletedOld = false;

    const locations = {
      findById: async () => ({ id: 'loc-1' }),
      getPhotoMediaAssetId: async () => 'asset-old',
      bindPhotoAsset: async () => undefined,
    } as unknown as ItemLocationRepository;

    const storage = {
      completeUpload: async () => ({
        id: 'asset-new',
        businessId: 'biz-1',
        storageKey: 'key',
        bucket: 'b',
        purpose: 'items',
        visibility: 'authenticated',
        mimeType: 'image/jpeg',
        fileSize: 100,
        etag: 'e',
        checksum: null,
        ownerType: 'rack',
        ownerId: 'loc-1',
        status: 'ready',
        uploadedBy: 'acc-1',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      }),
      resolveBusinessAssetUrl: async () => 'https://cdn/rack.jpg',
      deleteAsset: async (_b: string, _a: string, assetId: string) => {
        if (assetId === 'asset-old') deletedOld = true;
      },
    } as unknown as StorageService;

    const service = new ItemMediaService({
      config: baseConfig(),
      locationRepository: locations,
      storage,
    });

    const result = await service.completeRackPhotoUpload(
      'biz-1',
      'acc-1',
      'user-1',
      'loc-1',
      'intent-1',
    );

    expect(result.photo_media_asset_id).toBe('asset-new');
    expect(result.photo_url).toBe('https://cdn/rack.jpg');
    expect(deletedOld).toBe(true);
  });

  test('createItemImageUploadIntent delegates to storage with item policy', async () => {
    let capturedMax = 0;

    const items = {
      exists: async () => true,
      countImages: async () => 0,
    } as unknown as ItemRepository;

    const storage = {
      createUploadIntent: async (
        _b: string,
        _a: string,
        input: { ownerType?: string | null; purpose?: string },
        policy?: { maxBytes: number },
      ): Promise<UploadIntent> => {
        capturedMax = policy?.maxBytes ?? 0;
        expect(input.ownerType).toBe('item');
        expect(input.purpose).toBe('items');
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

    const service = new ItemMediaService({
      config: baseConfig(),
      itemRepository: items,
      storage,
    });

    const intent = await service.createItemImageUploadIntent(
      'biz-1',
      'acc-1',
      'item-1',
      'image/png',
      1024,
    );

    expect(intent.intentId).toBe('intent-1');
    expect(capturedMax).toBe(2 * 1024 * 1024);
  });
});
