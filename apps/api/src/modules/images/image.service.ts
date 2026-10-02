import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { MediaProcessingService } from '../media-processing/media-processing.service';
import type { MediaAssetRepository } from '../storage/storage.repository';
import { StorageService } from '../storage/storage.service';
import { type ImageVariant, isSourceImageMimeType } from './image.constants';
import { ImageNotFoundError, ImageValidationError } from './image.errors';
import { toImageVariantResponse } from './image.mapper';
import { ImageVariantRepository } from './image.repository';
import type { ImageVariantsResponse } from './image.types';

export type ImageServiceDeps = {
  config: AppConfig;
  storage?: StorageService;
  repository?: ImageVariantRepository;
  mediaProcessing?: MediaProcessingService;
  membership?: Pick<MediaAssetRepository, 'hasBusinessMembership'>;
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
  private readonly mediaProcessing: MediaProcessingService;
  private readonly membership: Pick<
    MediaAssetRepository,
    'hasBusinessMembership'
  >;

  constructor(deps: ImageServiceDeps) {
    this.config = deps.config;
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });
    this.repository =
      deps.repository ?? new ImageVariantRepository(requireDb());
    this.mediaProcessing =
      deps.mediaProcessing ??
      new MediaProcessingService({
        config: deps.config,
        storage: this.storage,
      });
    this.membership =
      deps.membership ??
      ({
        hasBusinessMembership: async () => true,
      } as Pick<MediaAssetRepository, 'hasBusinessMembership'>);
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
      throw new AppError(
        'FORBIDDEN',
        'You do not have access to this business',
        403,
      );
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

    await this.mediaProcessing.processAsset(
      businessId,
      accountId,
      sourceAssetId,
    );
    return this.listVariants(businessId, accountId, sourceAssetId);
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
    await this.mediaProcessing.deleteVariantsForSource(
      businessId,
      accountId,
      sourceMediaAssetId,
    );
  }
}

export { ImageNotFoundError, ImageValidationError };
