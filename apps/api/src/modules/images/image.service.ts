import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { StorageService } from '../storage/storage.service';
import type { MediaAssetRepository } from '../storage/storage.repository';
import {
  IMAGE_OUTPUT_MIME,
  IMAGE_WEBP_QUALITY,
  isSourceImageMimeType,
  type ImageVariant,
} from './image.constants';
import { ImageNotFoundError, ImageValidationError } from './image.errors';
import { buildImageVariantStoragePath } from './image-path.builder';
import { toImageVariantResponse } from './image.mapper';
import {
  generateImageVariants,
  readImageDimensions,
  validateImageDimensions,
} from './image.processor';
import { ImageVariantRepository } from './image.repository';
import type { ImageVariantsResponse } from './image.types';

export type ImageServiceDeps = {
  config: AppConfig;
  storage?: StorageService;
  repository?: ImageVariantRepository;
  membership?: Pick<MediaAssetRepository, 'hasBusinessMembership'>;
  generateVariants?: typeof generateImageVariants;
  readDimensions?: typeof readImageDimensions;
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

export class ImageService {
  private readonly config: AppConfig;
  private readonly storage: StorageService;
  private readonly repository: ImageVariantRepository;
  private readonly membership: Pick<MediaAssetRepository, 'hasBusinessMembership'>;
  private readonly generateVariants: typeof generateImageVariants;
  private readonly readDimensions: typeof readImageDimensions;

  constructor(deps: ImageServiceDeps) {
    this.config = deps.config;
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });
    this.repository =
      deps.repository ?? new ImageVariantRepository(requireDb());
    this.membership =
      deps.membership ??
      ({
        hasBusinessMembership: async () => true,
      } as Pick<MediaAssetRepository, 'hasBusinessMembership'>);
    this.generateVariants = deps.generateVariants ?? generateImageVariants;
    this.readDimensions = deps.readDimensions ?? readImageDimensions;
  }

  private async assertAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const allowed = await this.membership.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!allowed) {
      throw new AppError('FORBIDDEN', 'You do not have access to this business', 403);
    }
  }

  async processSourceAsset(
    businessId: string,
    accountId: string,
    sourceAssetId: string,
  ): Promise<ImageVariantsResponse> {
    await this.assertAccess(businessId, accountId);

    const source = await this.storage.getAsset(
      businessId,
      accountId,
      sourceAssetId,
    );

    if (!isSourceImageMimeType(source.mimeType)) {
      throw new ImageValidationError(
        'Only PNG, JPEG, and WEBP images can be processed',
        {
          mime_type: ['Source asset must be an image'],
        },
      );
    }

    const buffer = await this.storage.getObjectBuffer(
      businessId,
      accountId,
      sourceAssetId,
    );

    const dimensions = await this.readDimensions(buffer);
    validateImageDimensions(dimensions);

    const processed = await this.generateVariants(buffer, {
      webpQuality: IMAGE_WEBP_QUALITY,
    });

    const stored: ImageVariantsResponse['variants'] = [];

    for (const item of processed) {
      const existing = await this.repository.findBySourceAndVariant(
        businessId,
        sourceAssetId,
        item.variant,
      );

      let assetId: string;
      let storageKey: string;

      if (existing) {
        const asset = await this.storage.replaceObjectBuffer(
          businessId,
          accountId,
          existing.mediaAssetId,
          item.buffer,
          IMAGE_OUTPUT_MIME,
        );
        assetId = asset.id;
        storageKey = existing.storageKey;
      } else {
        storageKey = buildImageVariantStoragePath({
          environment: this.config.environment,
          businessId,
          sourceAssetId,
          variant: item.variant,
        });

        const asset = await this.storage.storeDerivativeFromBuffer(
          businessId,
          accountId,
          {
            storageKey,
            mimeType: IMAGE_OUTPUT_MIME,
            buffer: item.buffer,
            visibility: source.visibility,
            sourceAssetId,
          },
        );
        assetId = asset.id;
      }

      const record = await this.repository.upsertVariant({
        businessId,
        sourceMediaAssetId: sourceAssetId,
        variant: item.variant,
        mediaAssetId: assetId,
        width: item.width,
        height: item.height,
        fileSize: item.fileSize,
        mimeType: IMAGE_OUTPUT_MIME,
      });

      const download = await this.storage.getDownloadUrl(
        businessId,
        accountId,
        assetId,
      );

      stored.push(
        toImageVariantResponse(
          { ...record, storageKey },
          download.url,
          this.storage.resolvePublicCdnUrl(storageKey),
          download.expiresAt,
        ),
      );
    }

    return {
      source_media_asset_id: sourceAssetId,
      variants: stored,
    };
  }

  async listVariants(
    businessId: string,
    accountId: string,
    sourceAssetId: string,
  ): Promise<ImageVariantsResponse> {
    await this.assertAccess(businessId, accountId);

    const rows = await this.repository.listBySource(businessId, sourceAssetId);
    if (rows.length === 0) {
      throw new ImageNotFoundError('No image variants found for this asset');
    }

    const variants = await Promise.all(
      rows.map(async (row) => {
        const download = await this.storage.getDownloadUrl(
          businessId,
          accountId,
          row.mediaAssetId,
        );
        return toImageVariantResponse(
          row,
          download.url,
          this.storage.resolvePublicCdnUrl(row.storageKey),
          download.expiresAt,
        );
      }),
    );

    return {
      source_media_asset_id: sourceAssetId,
      variants,
    };
  }

  async getVariantUrl(
    businessId: string,
    accountId: string,
    sourceAssetId: string,
    variant: ImageVariant,
  ): Promise<ImageVariantsResponse['variants'][number]> {
    await this.assertAccess(businessId, accountId);

    const row = await this.repository.findBySourceAndVariant(
      businessId,
      sourceAssetId,
      variant,
    );
    if (!row) {
      throw new ImageNotFoundError(`Variant ${variant} not found`);
    }

    const download = await this.storage.getDownloadUrl(
      businessId,
      accountId,
      row.mediaAssetId,
    );

    return toImageVariantResponse(
      row,
      download.url,
      this.storage.resolvePublicCdnUrl(row.storageKey),
      download.expiresAt,
    );
  }

  async deleteVariantsForSource(
    businessId: string,
    accountId: string,
    sourceMediaAssetId: string,
  ): Promise<void> {
    const rows = await this.repository.listBySource(
      businessId,
      sourceMediaAssetId,
    );

    for (const row of rows) {
      try {
        await this.storage.deleteAsset(
          businessId,
          accountId,
          row.mediaAssetId,
          { skipVariantCleanup: true },
        );
      } catch {
        // Best-effort derivative cleanup.
      }
      await this.repository.softDeleteVariant(row.id);
    }

    await this.repository.softDeleteBySourceAssetId(sourceMediaAssetId);
  }
}

export { ImageNotFoundError, ImageValidationError };
