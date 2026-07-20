import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { mediaAssets } from '../../db/schema/storage/tables';
import { mediaImageVariants } from '../../db/schema/images/tables';
import type { ImageVariant } from './image.constants';
import type { ImageVariantRecord } from './image.types';

export type UpsertImageVariantValues = {
  businessId: string;
  sourceMediaAssetId: string;
  variant: ImageVariant;
  mediaAssetId: string;
  width: number;
  height: number;
  fileSize: number;
  mimeType: string;
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

  async listBySource(
    businessId: string,
    sourceMediaAssetId: string,
  ): Promise<ImageVariantRecord[]> {
    const rows = await this.db
      .select(selectColumns)
      .from(mediaImageVariants)
      .innerJoin(
        mediaAssets,
        eq(mediaImageVariants.mediaAssetId, mediaAssets.id),
      )
      .where(
        and(
          eq(mediaImageVariants.businessId, businessId),
          eq(mediaImageVariants.sourceMediaAssetId, sourceMediaAssetId),
          eq(mediaImageVariants.isDeleted, false),
          eq(mediaAssets.isDeleted, false),
        ),
      );

    return rows.map((row) => ({
      id: row.id,
      businessId: row.businessId,
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
    }));
  }

  async findBySourceAndVariant(
    businessId: string,
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
          eq(mediaImageVariants.businessId, businessId),
          eq(mediaImageVariants.sourceMediaAssetId, sourceMediaAssetId),
          eq(mediaImageVariants.variant, variant),
          eq(mediaImageVariants.isDeleted, false),
          eq(mediaAssets.isDeleted, false),
        ),
      )
      .limit(1);

    if (!row) return null;

    return {
      id: row.id,
      businessId: row.businessId,
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
}
