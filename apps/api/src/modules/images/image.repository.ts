import { and, eq, isNull } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { mediaImageVariants } from '../../db/schema/images/tables';
import { mediaAssets } from '../../db/schema/storage/tables';
import type { ImageVariantRecord } from '../images/image.types';
import type { ImageVariant } from '../media-processing/image/image.constants';

export type UpsertImageVariantValues = {
  businessId: string | null;
  sourceMediaAssetId: string;
  variant: ImageVariant;
  mediaAssetId: string;
  width: number;
  height: number;
  fileSize: number;
  mimeType: string;
  processingDurationMs?: number;
  compressionRatio?: number;
};

const selectColumns = {
  id: mediaImageVariants.id,
  businessId: mediaImageVariants.businessId,
  sourceMediaAssetId: mediaImageVariants.sourceMediaAssetId,
  variant: mediaImageVariants.variant,
  mediaAssetId: mediaImageVariants.mediaAssetId,
  width: mediaImageVariants.width,
  height: mediaImageVariants.height,
  fileSize: mediaImageVariants.fileSize,
  mimeType: mediaImageVariants.mimeType,
  storageKey: mediaAssets.storageKey,
  createdAt: mediaImageVariants.createdAt,
  updatedAt: mediaImageVariants.updatedAt,
};

export class ImageVariantRepository {
  constructor(private readonly db: Database) {}

  private sourceFilter(businessId: string | null, sourceMediaAssetId: string) {
    if (businessId) {
      return and(
        eq(mediaImageVariants.businessId, businessId),
        eq(mediaImageVariants.sourceMediaAssetId, sourceMediaAssetId),
        eq(mediaImageVariants.isDeleted, false),
        eq(mediaAssets.isDeleted, false),
      );
    }
    return and(
      isNull(mediaImageVariants.businessId),
      eq(mediaImageVariants.sourceMediaAssetId, sourceMediaAssetId),
      eq(mediaImageVariants.isDeleted, false),
      eq(mediaAssets.isDeleted, false),
    );
  }

  async listBySource(
    businessId: string,
    sourceMediaAssetId: string,
  ): Promise<ImageVariantRecord[]> {
    return this.listBySourceInternal(businessId, sourceMediaAssetId);
  }

  async listBySourceForAccount(
    accountId: string,
    sourceMediaAssetId: string,
  ): Promise<ImageVariantRecord[]> {
    void accountId;
    return this.listBySourceInternal(null, sourceMediaAssetId);
  }

  private async listBySourceInternal(
    businessId: string | null,
    sourceMediaAssetId: string,
  ): Promise<ImageVariantRecord[]> {
    const rows = await this.db
      .select(selectColumns)
      .from(mediaImageVariants)
      .innerJoin(
        mediaAssets,
        eq(mediaImageVariants.mediaAssetId, mediaAssets.id),
      )
      .where(this.sourceFilter(businessId, sourceMediaAssetId));

    return rows.map((row) => this.toRecord(row));
  }

  async findBySourceAndVariant(
    businessId: string | null,
    sourceMediaAssetId: string,
    variant: ImageVariant,
  ): Promise<ImageVariantRecord | null> {
    const [row] = await this.db
      .select(selectColumns)
      .from(mediaImageVariants)
      .innerJoin(
        mediaAssets,
        eq(mediaImageVariants.mediaAssetId, mediaAssets.id),
      )
      .where(
        and(
          this.sourceFilter(businessId, sourceMediaAssetId),
          eq(mediaImageVariants.variant, variant),
        ),
      )
      .limit(1);

    return row ? this.toRecord(row) : null;
  }

  async upsertVariant(
    values: UpsertImageVariantValues,
  ): Promise<ImageVariantRecord> {
    const existing = await this.findBySourceAndVariant(
      values.businessId,
      values.sourceMediaAssetId,
      values.variant,
    );

    if (existing) {
      const [updated] = await this.db
        .update(mediaImageVariants)
        .set({
          mediaAssetId: values.mediaAssetId,
          width: values.width,
          height: values.height,
          fileSize: values.fileSize,
          mimeType: values.mimeType,
          processingDurationMs: values.processingDurationMs ?? null,
          compressionRatio: values.compressionRatio ?? null,
          updatedAt: new Date(),
        })
        .where(eq(mediaImageVariants.id, existing.id))
        .returning({
          id: mediaImageVariants.id,
          businessId: mediaImageVariants.businessId,
          sourceMediaAssetId: mediaImageVariants.sourceMediaAssetId,
          variant: mediaImageVariants.variant,
          mediaAssetId: mediaImageVariants.mediaAssetId,
          width: mediaImageVariants.width,
          height: mediaImageVariants.height,
          fileSize: mediaImageVariants.fileSize,
          mimeType: mediaImageVariants.mimeType,
          createdAt: mediaImageVariants.createdAt,
          updatedAt: mediaImageVariants.updatedAt,
        });

      if (!updated) {
        throw new Error('Failed to update image variant');
      }

      const [asset] = await this.db
        .select({ storageKey: mediaAssets.storageKey })
        .from(mediaAssets)
        .where(eq(mediaAssets.id, values.mediaAssetId))
        .limit(1);

      return {
        ...updated,
        businessId: updated.businessId ?? '',
        variant: updated.variant as ImageVariant,
        storageKey: asset?.storageKey ?? existing.storageKey,
      };
    }

    const [inserted] = await this.db
      .insert(mediaImageVariants)
      .values({
        businessId: values.businessId,
        sourceMediaAssetId: values.sourceMediaAssetId,
        variant: values.variant,
        mediaAssetId: values.mediaAssetId,
        width: values.width,
        height: values.height,
        fileSize: values.fileSize,
        mimeType: values.mimeType,
        processingDurationMs: values.processingDurationMs ?? null,
        compressionRatio: values.compressionRatio ?? null,
      })
      .returning({
        id: mediaImageVariants.id,
        businessId: mediaImageVariants.businessId,
        sourceMediaAssetId: mediaImageVariants.sourceMediaAssetId,
        variant: mediaImageVariants.variant,
        mediaAssetId: mediaImageVariants.mediaAssetId,
        width: mediaImageVariants.width,
        height: mediaImageVariants.height,
        fileSize: mediaImageVariants.fileSize,
        mimeType: mediaImageVariants.mimeType,
        createdAt: mediaImageVariants.createdAt,
        updatedAt: mediaImageVariants.updatedAt,
      });

    if (!inserted) {
      throw new Error('Failed to insert image variant');
    }

    const [asset] = await this.db
      .select({ storageKey: mediaAssets.storageKey })
      .from(mediaAssets)
      .where(eq(mediaAssets.id, values.mediaAssetId))
      .limit(1);

    return {
      ...inserted,
      businessId: inserted.businessId ?? '',
      variant: inserted.variant as ImageVariant,
      storageKey: asset?.storageKey ?? '',
    };
  }

  async softDeleteBySourceAssetId(sourceMediaAssetId: string): Promise<void> {
    await this.db
      .update(mediaImageVariants)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(mediaImageVariants.sourceMediaAssetId, sourceMediaAssetId),
          eq(mediaImageVariants.isDeleted, false),
        ),
      );
  }

  async softDeleteVariant(id: string): Promise<void> {
    await this.db
      .update(mediaImageVariants)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(mediaImageVariants.id, id));
  }

  private toRecord(row: {
    id: string;
    businessId: string | null;
    sourceMediaAssetId: string;
    variant: string;
    mediaAssetId: string;
    width: number;
    height: number;
    fileSize: number;
    mimeType: string;
    storageKey: string;
    createdAt: Date;
    updatedAt: Date;
  }): ImageVariantRecord {
    return {
      id: row.id,
      businessId: row.businessId ?? '',
      sourceMediaAssetId: row.sourceMediaAssetId,
      variant: row.variant as ImageVariant,
      mediaAssetId: row.mediaAssetId,
      width: row.width,
      height: row.height,
      fileSize: row.fileSize,
      mimeType: row.mimeType,
      storageKey: row.storageKey,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }
}
