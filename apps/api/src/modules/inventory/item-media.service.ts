import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { ImageService } from '../images/image.service';
import type { ImageVariant } from '../media-processing/image/image.constants';
import { StorageNotFoundError } from '../storage/storage.errors';
import { StorageService } from '../storage/storage.service';
import type { UploadIntent } from '../storage/storage.types';
import { InventoryServiceBase } from './inventory.base-service';
import {
  ITEM_IMAGE_POLICY,
  MAX_ITEM_GALLERY_IMAGES,
  RACK_PHOTO_POLICY,
} from './item-media.constants';
import { ItemLocationRepository } from './item-location.repository';
import { ItemRepository } from './item.repository';
import type { ItemImageRecord } from './item.types';

export type ItemMediaAssetResponse = {
  id: string;
  image_url: string;
  thumbnail_url?: string | null;
  medium_url?: string | null;
  sort_order: number;
  is_primary: boolean;
  media_asset_id: string | null;
  created_at: string;
  updated_at: string;
};

export type RackPhotoResponse = {
  photo_url: string;
  photo_media_asset_id: string;
  photo_taken_at: string;
};

export type ItemMediaServiceDeps = {
  config: AppConfig;
  itemRepository?: ItemRepository;
  locationRepository?: ItemLocationRepository;
  storage?: StorageService;
  logger?: {
    info: (obj: object, msg?: string) => void;
  };
};

function requireDb() {
  const db = getDb();
  if (!db) {
    throw new AppError(
      'DATABASE_NOT_CONFIGURED',
      'Database is not configured',
      503,
    );
  }
  return db;
}

export class ItemMediaService extends InventoryServiceBase {
  private readonly items: ItemRepository;
  private readonly locations: ItemLocationRepository;
  private readonly storage: StorageService;
  private readonly config: AppConfig;
  private readonly log: ItemMediaServiceDeps['logger'];

  constructor(deps: ItemMediaServiceDeps) {
    super();
    const db = requireDb();
    this.config = deps.config;
    this.items = deps.itemRepository ?? new ItemRepository(db);
    this.locations = deps.locationRepository ?? new ItemLocationRepository(db);
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });
    this.log = deps.logger;
  }

  async createItemImageUploadIntent(
    businessId: string,
    accountId: string,
    itemId: string,
    mimeType: string,
    fileSize: number,
    checksum?: string | null,
  ): Promise<UploadIntent> {
    await this.assertItemExists(businessId, itemId);

    const count = await this.items.countImages(businessId, itemId);
    if (count >= MAX_ITEM_GALLERY_IMAGES) {
      throw new AppError(
        'VALIDATION_ERROR',
        `Maximum ${MAX_ITEM_GALLERY_IMAGES} gallery images allowed per item`,
        400,
        { file_size: ['Gallery image limit reached'] },
      );
    }

    return this.storage.createUploadIntent(
      businessId,
      accountId,
      {
        purpose: 'items',
        visibility: 'authenticated',
        mimeType,
        fileSize,
        ownerType: 'item',
        ownerId: itemId,
        checksum,
      },
      ITEM_IMAGE_POLICY,
    );
  }

  async completeItemImageUpload(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    intentId: string,
    options: {
      isPrimary?: boolean;
      sortOrder?: number;
      replacesImageId?: string | null;
    } = {},
  ): Promise<ItemMediaAssetResponse> {
    await this.assertItemExists(businessId, itemId);

    const asset = await this.storage.completeUpload(
      businessId,
      accountId,
      intentId,
    );

    if (asset.purpose !== 'items' || asset.ownerType !== 'item') {
      throw new AppError(
        'VALIDATION_ERROR',
        'Upload intent does not match item gallery',
        400,
      );
    }

    const url = await this.storage.resolveBusinessAssetUrl(
      businessId,
      accountId,
      asset.id,
    );

    const existingCount = await this.items.countImages(businessId, itemId);
    const isPrimary =
      options.isPrimary ?? existingCount === 0;
    const sortOrder =
      options.sortOrder ??
      (existingCount > 0 ? existingCount : 0);

    const image = await this.items.addImage(businessId, itemId, {
      imageUrl: url,
      mediaAssetId: asset.id,
      sortOrder,
      isPrimary,
      createdBy: userId ?? null,
      updatedBy: userId ?? null,
    });

    if (options.replacesImageId) {
      await this.deleteItemImageMedia(
        businessId,
        accountId,
        userId,
        itemId,
        options.replacesImageId,
        { skipNotFound: true },
      );
    }

    return this.toMediaResponse(image, asset.id);
  }

  async deleteItemImageMedia(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    imageId: string,
    options: { skipNotFound?: boolean } = {},
  ): Promise<void> {
    await this.assertItemExists(businessId, itemId);

    const image = await this.items.findImageById(businessId, itemId, imageId);
    if (!image) {
      if (options.skipNotFound) return;
      throw new AppError('NOT_FOUND', 'Item image not found', 404);
    }

    const mediaAssetId = await this.items.getImageMediaAssetId(
      businessId,
      itemId,
      imageId,
    );

    const deleted = await this.items.softDeleteImage(
      businessId,
      itemId,
      imageId,
      userId ?? null,
    );

    if (!deleted) {
      if (options.skipNotFound) return;
      throw new AppError('NOT_FOUND', 'Item image not found', 404);
    }

    if (mediaAssetId) {
      try {
        await this.storage.deleteAsset(businessId, accountId, mediaAssetId);
      } catch (error) {
        if (!(error instanceof StorageNotFoundError)) {
          throw error;
        }
      }
    }
  }

  async reorderItemImages(
    businessId: string,
    accountId: string,
    itemId: string,
    imageIds: string[],
  ): Promise<ItemImageRecord[]> {
    await this.assertBusinessItemAccess(businessId, accountId, itemId);
    return this.items.reorderImages(businessId, itemId, imageIds);
  }

  async setPrimaryItemImage(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    itemId: string,
    imageId: string,
  ): Promise<ItemImageRecord> {
    await this.assertBusinessItemAccess(businessId, accountId, itemId);

    const updated = await this.items.updateImage(businessId, itemId, imageId, {
      isPrimary: true,
      updatedBy: userId ?? null,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Item image not found', 404);
    }

    return updated;
  }

  async enrichItemImages(
    businessId: string,
    accountId: string,
    images: ItemImageRecord[],
  ): Promise<ItemImageRecord[]> {
    return Promise.all(
      images.map(async (image) => {
        const mediaAssetId = await this.items.getImageMediaAssetIdByImageId(
          businessId,
          image.id,
        );
        if (!mediaAssetId) return image;

        try {
          const [url, thumbnailUrl, mediumUrl] = await Promise.all([
            this.storage.resolveBusinessAssetUrl(
              businessId,
              accountId,
              mediaAssetId,
            ),
            this.resolveVariantUrlOrSource(
              businessId,
              accountId,
              mediaAssetId,
              'thumbnail',
            ),
            this.resolveVariantUrlOrSource(
              businessId,
              accountId,
              mediaAssetId,
              'medium',
            ),
          ]);
          return {
            ...image,
            image_url: url,
            thumbnail_url: thumbnailUrl,
            medium_url: mediumUrl,
          };
        } catch {
          return image;
        }
      }),
    );
  }

  async resolvePrimaryImageUrl(
    businessId: string,
    accountId: string,
    itemId: string,
    fallbackUrl: string | null,
  ): Promise<string | null> {
    const primaryAssetId = await this.items.getPrimaryImageMediaAssetId(
      businessId,
      itemId,
    );
    if (!primaryAssetId) return fallbackUrl;

    try {
      return await this.resolveVariantUrlOrSource(
        businessId,
        accountId,
        primaryAssetId,
        'thumbnail',
      );
    } catch {
      return fallbackUrl;
    }
  }

  private imageService(): ImageService {
    return new ImageService({
      config: this.config,
      storage: this.storage,
    });
  }

  private async resolveVariantUrlOrSource(
    businessId: string,
    accountId: string,
    mediaAssetId: string,
    variant: ImageVariant,
  ): Promise<string> {
    try {
      const variantUrl = await this.imageService().getVariantUrl(
        businessId,
        accountId,
        mediaAssetId,
        variant,
      );
      return variantUrl.url;
    } catch {
      return this.storage.resolveBusinessAssetUrl(
        businessId,
        accountId,
        mediaAssetId,
      );
    }
  }

  async createRackPhotoUploadIntent(
    businessId: string,
    accountId: string,
    locationId: string,
    mimeType: string,
    fileSize: number,
    checksum?: string | null,
  ): Promise<UploadIntent> {
    await this.assertLocationExists(businessId, locationId);

    return this.storage.createUploadIntent(
      businessId,
      accountId,
      {
        purpose: 'items',
        visibility: 'authenticated',
        mimeType,
        fileSize,
        ownerType: 'rack',
        ownerId: locationId,
        checksum,
      },
      RACK_PHOTO_POLICY,
    );
  }

  async completeRackPhotoUpload(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    locationId: string,
    intentId: string,
  ): Promise<RackPhotoResponse> {
    await this.assertLocationExists(businessId, locationId);

    const asset = await this.storage.completeUpload(
      businessId,
      accountId,
      intentId,
    );

    if (asset.purpose !== 'items' || asset.ownerType !== 'rack') {
      throw new AppError(
        'VALIDATION_ERROR',
        'Upload intent does not match rack photo',
        400,
      );
    }

    const previousAssetId =
      await this.locations.getPhotoMediaAssetId(businessId, locationId);

    const url = await this.storage.resolveBusinessAssetUrl(
      businessId,
      accountId,
      asset.id,
    );

    const now = new Date();
    await this.locations.bindPhotoAsset(
      businessId,
      locationId,
      asset.id,
      url,
      now,
      userId ?? null,
    );

    if (previousAssetId && previousAssetId !== asset.id) {
      try {
        await this.storage.deleteAsset(businessId, accountId, previousAssetId);
      } catch (error) {
        if (!(error instanceof StorageNotFoundError)) {
          throw error;
        }
      }
    }

    return {
      photo_url: url,
      photo_media_asset_id: asset.id,
      photo_taken_at: now.toISOString(),
    };
  }

  async deleteRackPhoto(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    locationId: string,
  ): Promise<void> {
    await this.assertLocationExists(businessId, locationId);

    const assetId = await this.locations.getPhotoMediaAssetId(
      businessId,
      locationId,
    );
    if (!assetId) {
      throw new AppError('NOT_FOUND', 'Rack photo not found', 404);
    }

    await this.locations.clearPhotoAsset(businessId, locationId, userId ?? null);

    try {
      await this.storage.deleteAsset(businessId, accountId, assetId);
    } catch (error) {
      if (!(error instanceof StorageNotFoundError)) {
        throw error;
      }
    }
  }

  async resolveRackPhotoUrl(
    businessId: string,
    accountId: string,
    locationId: string,
    fallbackUrl: string | null,
  ): Promise<string | null> {
    const assetId = await this.locations.getPhotoMediaAssetId(
      businessId,
      locationId,
    );
    if (!assetId) return fallbackUrl;

    try {
      return await this.storage.resolveBusinessAssetUrl(
        businessId,
        accountId,
        assetId,
      );
    } catch {
      return fallbackUrl;
    }
  }

  private toMediaResponse(
    image: ItemImageRecord,
    mediaAssetId: string,
  ): ItemMediaAssetResponse {
    return {
      id: image.id,
      image_url: image.image_url,
      thumbnail_url: image.thumbnail_url ?? null,
      medium_url: image.medium_url ?? null,
      sort_order: image.sort_order,
      is_primary: image.is_primary,
      media_asset_id: mediaAssetId,
      created_at: image.created_at,
      updated_at: image.updated_at,
    };
  }

  private async assertItemExists(
    businessId: string,
    itemId: string,
  ): Promise<void> {
    const exists = await this.items.exists(businessId, itemId);
    if (!exists) {
      throw new AppError('NOT_FOUND', 'Item not found', 404);
    }
  }

  private async assertLocationExists(
    businessId: string,
    locationId: string,
  ): Promise<void> {
    const row = await this.locations.findById(businessId, locationId);
    if (!row) {
      throw new AppError('NOT_FOUND', 'Item location not found', 404);
    }
  }

  private async assertBusinessItemAccess(
    businessId: string,
    accountId: string,
    itemId: string,
  ): Promise<void> {
    await this.assertBusinessAccess(businessId, accountId);
    await this.assertItemExists(businessId, itemId);
  }
}
