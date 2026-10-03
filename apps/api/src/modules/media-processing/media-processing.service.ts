import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { ImageVariantRepository } from '../images/image.repository';
import { toStorageAsset } from '../storage/storage.mapper';
import { MediaAssetRepository } from '../storage/storage.repository';
import type { StorageService } from '../storage/storage.service';
import type {
  MediaAssetRow,
  ProcessingStatus,
  StorageAsset,
} from '../storage/storage.types';
import type { ImageVariant } from './image/image.constants';
import { buildProcessedImagePath } from './image/image-path.builder';
import {
  IMAGE_POLICIES,
  type ImagePolicyKey,
  resolveImagePolicy,
  shouldProcessAsset,
} from './media-processing.constants';
import {
  globalMediaProcessingMetrics,
  type MediaProcessingMetrics,
} from './media-processing.metrics';
import type { ProcessedVariantOutput } from './media-processing.types';
import { ImageMediaProcessor } from './processors/image.processor';

export type MediaProcessingServiceDeps = {
  config: AppConfig;
  storage: StorageService;
  assetRepository?: MediaAssetRepository;
  variantRepository?: ImageVariantRepository;
  processor?: ImageMediaProcessor;
  metrics?: MediaProcessingMetrics;
  logger?: {
    info: (obj: object, msg?: string) => void;
    warn: (obj: object, msg?: string) => void;
    error: (obj: object, msg?: string) => void;
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

export class MediaProcessingService {
  private readonly config: AppConfig;
  private readonly storage: StorageService;
  private readonly assets: MediaAssetRepository;
  private readonly variants: ImageVariantRepository;
  private readonly processor: ImageMediaProcessor;
  private readonly metrics: MediaProcessingMetrics;
  private readonly log: NonNullable<MediaProcessingServiceDeps['logger']>;

  constructor(deps: MediaProcessingServiceDeps) {
    this.config = deps.config;
    this.storage = deps.storage;
    this.assets = deps.assetRepository ?? new MediaAssetRepository(requireDb());
    this.variants =
      deps.variantRepository ?? new ImageVariantRepository(requireDb());
    this.processor = deps.processor ?? new ImageMediaProcessor();
    this.metrics = deps.metrics ?? globalMediaProcessingMetrics;
    this.log = deps.logger ?? {
      info: () => undefined,
      warn: () => undefined,
      error: () => undefined,
    };
  }

  static shouldProcess(asset: StorageAsset | MediaAssetRow): boolean {
    return shouldProcessAsset({
      purpose: asset.purpose as StorageAsset['purpose'],
      mimeType: asset.mimeType,
      ownerType: asset.ownerType,
      businessId: asset.businessId,
    });
  }

  async processAsset(
    businessId: string | null,
    accountId: string,
    assetId: string,
  ): Promise<void> {
    const row = await this.loadAssetRow(businessId, accountId, assetId);
    if (!row || row.status !== 'ready') {
      return;
    }

    const policy = resolveImagePolicy({
      purpose: row.purpose as StorageAsset['purpose'],
      mimeType: row.mimeType,
      ownerType: row.ownerType,
      businessId: row.businessId,
    });

    if (policy.key === 'SKIP' || !policy.optimize) {
      await this.assets.updateProcessingStatus(row.id, 'skipped');
      this.metrics.recordSkipped();
      return;
    }

    await this.assets.updateProcessingStatus(row.id, 'processing');

    const readKey = row.stagingStorageKey ?? row.storageKey;
    let sourceBuffer: Buffer;

    try {
      sourceBuffer = await this.storage.getObjectBufferByKey(readKey);
    } catch (error) {
      await this.assets.updateProcessingStatus(row.id, 'failed');
      this.metrics.recordFailure();
      this.log.error(
        {
          event: 'media.processing_failed',
          assetId,
          step: 'read_staging',
          error: error instanceof Error ? error.message : 'unknown',
        },
        'Failed to read staging object for media processing',
      );
      return;
    }

    const asset = toStorageAsset(row);

    try {
      const result = await this.processor.process({
        businessId: row.businessId,
        accountId,
        asset,
        assetRow: row,
        policyKey: policy.key as Exclude<ImagePolicyKey, 'SKIP'>,
        stagingStorageKey: readKey,
        sourceBuffer,
        originalSize: row.originalSize ?? row.fileSize,
      });

      await this.persistProcessedAsset(row, accountId, policy.key, result);

      if (row.stagingStorageKey && row.stagingStorageKey !== row.storageKey) {
        await this.storage.deleteObjectByKey(row.stagingStorageKey);
      }

      this.metrics.recordSuccess({
        originalSize: result.originalSize,
        optimizedSize: result.optimizedSize,
        variantCount: result.variants.length,
        durationMs: result.durationMs,
      });

      this.log.info(
        {
          event: 'media.processing_complete',
          assetId,
          purpose: row.purpose,
          policy: policy.key,
          durationMs: result.durationMs,
          originalSize: result.originalSize,
          optimizedSize: result.optimizedSize,
          compressionRatio: result.compressionRatio,
          variants: result.variants.map((item) => item.variant),
          format: result.format,
        },
        'Media processing completed',
      );
    } catch (error) {
      await this.assets.updateProcessingStatus(row.id, 'failed');
      this.metrics.recordFailure();
      this.log.error(
        {
          event: 'media.processing_failed',
          assetId,
          step: 'pipeline',
          error: error instanceof Error ? error.message : 'unknown',
        },
        'Media processing failed',
      );
    }
  }

  private async loadAssetRow(
    businessId: string | null,
    accountId: string,
    assetId: string,
  ): Promise<MediaAssetRow | null> {
    if (businessId) {
      return this.assets.findById(businessId, assetId);
    }
    return this.assets.findByIdForAccount(accountId, assetId);
  }

  private async persistProcessedAsset(
    row: MediaAssetRow,
    accountId: string,
    policyKey: ImagePolicyKey,
    result: Awaited<ReturnType<ImageMediaProcessor['process']>>,
  ): Promise<void> {
    const policy = IMAGE_POLICIES[policyKey as Exclude<ImagePolicyKey, 'SKIP'>];
    const originalVariant = result.variants.find(
      (v) => v.variant === 'original',
    );
    if (!originalVariant) {
      throw new Error('Pipeline did not produce an original variant');
    }

    const originalPath = buildProcessedImagePath({
      environment: this.config.environment,
      businessId: row.businessId,
      accountId: row.businessId ? undefined : accountId,
      purpose: row.purpose as StorageAsset['purpose'],
      assetId: row.id,
      variant: 'original',
      format: originalVariant.encoded.format,
      ownerType: row.ownerType,
      ownerId: row.ownerId,
    });

    await this.storage.putObjectAtKey(
      originalPath,
      originalVariant.encoded.buffer,
      originalVariant.encoded.mimeType,
    );

    if (
      row.storageKey !== originalPath &&
      row.storageKey !== row.stagingStorageKey
    ) {
      try {
        await this.storage.deleteObjectByKey(row.storageKey);
      } catch {
        // Best-effort cleanup of pre-canonical key.
      }
    }

    await this.assets.updateAfterProcessing(row.id, {
      storageKey: originalPath,
      mimeType: originalVariant.encoded.mimeType,
      fileSize: originalVariant.encoded.fileSize,
      width: originalVariant.encoded.width,
      height: originalVariant.encoded.height,
      format: originalVariant.encoded.format,
      variantType: 'original',
      originalSize: result.originalSize,
      optimizedSize: result.optimizedSize,
      compressionRatio: result.compressionRatio,
      processingStatus: 'ready' as ProcessingStatus,
      stagingStorageKey: null,
    });

    if (policy.generateVariants) {
      for (const item of result.variants) {
        if (item.variant === 'original') {
          await this.upsertVariantRecord(
            row,
            accountId,
            item.variant,
            row.id,
            item,
            result,
          );
          continue;
        }

        const variantPath = buildProcessedImagePath({
          environment: this.config.environment,
          businessId: row.businessId,
          accountId: row.businessId ? undefined : accountId,
          purpose: row.purpose as StorageAsset['purpose'],
          assetId: row.id,
          variant: item.variant,
          format: item.encoded.format,
          ownerType: row.ownerType,
          ownerId: row.ownerId,
        });

        const existing = await this.variants.findBySourceAndVariant(
          row.businessId,
          row.id,
          item.variant,
        );

        let variantAssetId: string;

        if (existing) {
          await this.storage.putObjectAtKey(
            variantPath,
            item.encoded.buffer,
            item.encoded.mimeType,
          );
          await this.assets.updateAfterProcessing(existing.mediaAssetId, {
            storageKey: variantPath,
            mimeType: item.encoded.mimeType,
            fileSize: item.encoded.fileSize,
            width: item.encoded.width,
            height: item.encoded.height,
            format: item.encoded.format,
            variantType: item.variant,
            parentAssetId: row.id,
            originalSize: null,
            optimizedSize: item.encoded.fileSize,
            compressionRatio: null,
            processingStatus: 'ready',
            stagingStorageKey: null,
          });
          variantAssetId = existing.mediaAssetId;
        } else {
          variantAssetId = await this.storage.storeProcessedVariant({
            businessId: row.businessId,
            accountId,
            sourceAssetId: row.id,
            storageKey: variantPath,
            mimeType: item.encoded.mimeType,
            buffer: item.encoded.buffer,
            visibility: row.visibility as StorageAsset['visibility'],
            purpose: row.purpose as StorageAsset['purpose'],
            variantType: item.variant,
            ownerType: row.ownerType,
            ownerId: row.ownerId,
          });
        }

        await this.upsertVariantRecord(
          row,
          accountId,
          item.variant,
          variantAssetId,
          item,
          result,
        );
      }
    }
  }

  private async upsertVariantRecord(
    row: MediaAssetRow,
    _accountId: string,
    variant: ImageVariant,
    mediaAssetId: string,
    item: ProcessedVariantOutput,
    result: Awaited<ReturnType<ImageMediaProcessor['process']>>,
  ): Promise<void> {
    await this.variants.upsertVariant({
      businessId: row.businessId,
      sourceMediaAssetId: row.id,
      variant,
      mediaAssetId,
      width: item.encoded.width,
      height: item.encoded.height,
      fileSize: item.encoded.fileSize,
      mimeType: item.encoded.mimeType,
      processingDurationMs: result.durationMs,
      compressionRatio: result.compressionRatio,
    });
  }

  async deleteVariantsForSource(
    businessId: string | null,
    accountId: string,
    sourceMediaAssetId: string,
    stagingStorageKey?: string | null,
  ): Promise<void> {
    const rows = businessId
      ? await this.variants.listBySource(businessId, sourceMediaAssetId)
      : await this.variants.listBySourceForAccount(
          accountId,
          sourceMediaAssetId,
        );

    for (const variantRow of rows) {
      if (variantRow.variant === 'original') {
        continue;
      }
      try {
        if (businessId) {
          await this.storage.deleteAsset(
            businessId,
            accountId,
            variantRow.mediaAssetId,
            {
              skipVariantCleanup: true,
              skipMediaProcessing: true,
            },
          );
        } else {
          await this.storage.deleteAccountAsset(
            accountId,
            variantRow.mediaAssetId,
          );
        }
      } catch {
        // Best-effort variant cleanup.
      }
      await this.variants.softDeleteVariant(variantRow.id);
    }

    await this.variants.softDeleteBySourceAssetId(sourceMediaAssetId);

    if (stagingStorageKey) {
      try {
        await this.storage.deleteObjectByKey(stagingStorageKey);
      } catch {
        // Best-effort staging cleanup.
      }
    }
  }
}
