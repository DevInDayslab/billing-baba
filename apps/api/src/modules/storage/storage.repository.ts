import { and, eq, isNull } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { mediaAssets } from '../../db/schema/storage/tables';
import { BusinessMembershipRepository } from '../../shared/repositories/business-membership.repository';
import type { MediaAssetRow, ProcessingStatus } from './storage.types';

export type InsertMediaAssetValues = {
  id: string;
  businessId: string | null;
  storageKey: string;
  bucket: string;
  purpose: string;
  visibility: string;
  mimeType: string;
  fileSize: number;
  checksum?: string | null;
  ownerType?: string | null;
  ownerId?: string | null;
  status: string;
  uploadedBy?: string | null;
  stagingStorageKey?: string | null;
  processingStatus?: ProcessingStatus;
};

export type MarkReadyValues = {
  etag: string | null;
  fileSize: number;
  mimeType?: string;
};

export type UpdateAfterProcessingValues = {
  storageKey: string;
  mimeType: string;
  fileSize: number;
  width: number;
  height: number;
  format: string;
  variantType: string;
  parentAssetId?: string | null;
  originalSize: number | null;
  optimizedSize: number | null;
  compressionRatio: number | null;
  processingStatus: ProcessingStatus;
  stagingStorageKey: string | null;
};

const selectColumns = {
  id: mediaAssets.id,
  businessId: mediaAssets.businessId,
  storageKey: mediaAssets.storageKey,
  bucket: mediaAssets.bucket,
  purpose: mediaAssets.purpose,
  visibility: mediaAssets.visibility,
  mimeType: mediaAssets.mimeType,
  fileSize: mediaAssets.fileSize,
  etag: mediaAssets.etag,
  checksum: mediaAssets.checksum,
  ownerType: mediaAssets.ownerType,
  ownerId: mediaAssets.ownerId,
  status: mediaAssets.status,
  uploadedBy: mediaAssets.uploadedBy,
  width: mediaAssets.width,
  height: mediaAssets.height,
  format: mediaAssets.format,
  variantType: mediaAssets.variantType,
  parentAssetId: mediaAssets.parentAssetId,
  originalSize: mediaAssets.originalSize,
  optimizedSize: mediaAssets.optimizedSize,
  compressionRatio: mediaAssets.compressionRatio,
  processedAt: mediaAssets.processedAt,
  processingStatus: mediaAssets.processingStatus,
  stagingStorageKey: mediaAssets.stagingStorageKey,
  createdAt: mediaAssets.createdAt,
  updatedAt: mediaAssets.updatedAt,
  deletedAt: mediaAssets.deletedAt,
  isDeleted: mediaAssets.isDeleted,
};

export class MediaAssetRepository {
  private readonly membership: BusinessMembershipRepository;

  constructor(private readonly db: Database) {
    this.membership = new BusinessMembershipRepository(db);
  }

  async hasBusinessMembership(
    businessId: string,
    accountId: string,
  ): Promise<boolean> {
    return this.membership.hasBusinessMembership(businessId, accountId);
  }

  async insert(values: InsertMediaAssetValues): Promise<MediaAssetRow> {
    const [row] = await this.db
      .insert(mediaAssets)
      .values({
        id: values.id,
        businessId: values.businessId,
        storageKey: values.storageKey,
        bucket: values.bucket,
        purpose: values.purpose,
        visibility: values.visibility,
        mimeType: values.mimeType,
        fileSize: values.fileSize,
        checksum: values.checksum ?? null,
        ownerType: values.ownerType ?? null,
        ownerId: values.ownerId ?? null,
        status: values.status,
        uploadedBy: values.uploadedBy ?? null,
        stagingStorageKey: values.stagingStorageKey ?? null,
        processingStatus: values.processingStatus ?? 'pending',
      })
      .returning(selectColumns);

    if (!row) {
      throw new Error('Failed to insert media asset');
    }
    return row;
  }

  async findById(
    businessId: string,
    id: string,
  ): Promise<MediaAssetRow | null> {
    const [row] = await this.db
      .select(selectColumns)
      .from(mediaAssets)
      .where(
        and(
          eq(mediaAssets.id, id),
          eq(mediaAssets.businessId, businessId),
          eq(mediaAssets.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async markReady(
    businessId: string,
    id: string,
    values: MarkReadyValues,
  ): Promise<MediaAssetRow | null> {
    const [row] = await this.db
      .update(mediaAssets)
      .set({
        status: 'ready',
        etag: values.etag,
        fileSize: values.fileSize,
        originalSize: values.fileSize,
        ...(values.mimeType !== undefined ? { mimeType: values.mimeType } : {}),
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(mediaAssets.id, id),
          eq(mediaAssets.businessId, businessId),
          eq(mediaAssets.isDeleted, false),
          eq(mediaAssets.status, 'pending'),
        ),
      )
      .returning(selectColumns);

    return row ?? null;
  }

  async updateProcessingStatus(
    id: string,
    processingStatus: ProcessingStatus,
  ): Promise<void> {
    await this.db
      .update(mediaAssets)
      .set({
        processingStatus,
        updatedAt: new Date(),
        ...(processingStatus === 'ready'
          ? { processedAt: new Date() }
          : {}),
      })
      .where(eq(mediaAssets.id, id));
  }

  async updateAfterProcessing(
    id: string,
    values: UpdateAfterProcessingValues,
  ): Promise<void> {
    await this.db
      .update(mediaAssets)
      .set({
        storageKey: values.storageKey,
        mimeType: values.mimeType,
        fileSize: values.fileSize,
        width: values.width,
        height: values.height,
        format: values.format,
        variantType: values.variantType,
        parentAssetId: values.parentAssetId ?? null,
        originalSize: values.originalSize,
        optimizedSize: values.optimizedSize,
        compressionRatio: values.compressionRatio,
        processingStatus: values.processingStatus,
        stagingStorageKey: values.stagingStorageKey,
        processedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(mediaAssets.id, id));
  }

  async findByIdForAccount(
    accountId: string,
    id: string,
  ): Promise<MediaAssetRow | null> {
    const [row] = await this.db
      .select(selectColumns)
      .from(mediaAssets)
      .where(
        and(
          eq(mediaAssets.id, id),
          isNull(mediaAssets.businessId),
          eq(mediaAssets.ownerType, 'avatar'),
          eq(mediaAssets.ownerId, accountId),
          eq(mediaAssets.isDeleted, false),
        ),
      )
      .limit(1);

    return row ?? null;
  }

  async markReadyForAccount(
    accountId: string,
    id: string,
    values: MarkReadyValues,
  ): Promise<MediaAssetRow | null> {
    const [row] = await this.db
      .update(mediaAssets)
      .set({
        status: 'ready',
        etag: values.etag,
        fileSize: values.fileSize,
        originalSize: values.fileSize,
        ...(values.mimeType !== undefined ? { mimeType: values.mimeType } : {}),
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(mediaAssets.id, id),
          isNull(mediaAssets.businessId),
          eq(mediaAssets.ownerType, 'avatar'),
          eq(mediaAssets.ownerId, accountId),
          eq(mediaAssets.isDeleted, false),
          eq(mediaAssets.status, 'pending'),
        ),
      )
      .returning(selectColumns);

    return row ?? null;
  }

  async softDeleteForAccount(
    accountId: string,
    id: string,
  ): Promise<MediaAssetRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(mediaAssets)
      .set({
        isDeleted: true,
        deletedAt: now,
        updatedAt: now,
      })
      .where(
        and(
          eq(mediaAssets.id, id),
          isNull(mediaAssets.businessId),
          eq(mediaAssets.ownerType, 'avatar'),
          eq(mediaAssets.ownerId, accountId),
          eq(mediaAssets.isDeleted, false),
        ),
      )
      .returning(selectColumns);

    return row ?? null;
  }

  async softDelete(
    businessId: string,
    id: string,
  ): Promise<MediaAssetRow | null> {
    const now = new Date();
    const [row] = await this.db
      .update(mediaAssets)
      .set({
        isDeleted: true,
        deletedAt: now,
        updatedAt: now,
      })
      .where(
        and(
          eq(mediaAssets.id, id),
          eq(mediaAssets.businessId, businessId),
          eq(mediaAssets.isDeleted, false),
        ),
      )
      .returning(selectColumns);

    return row ?? null;
  }

  async listChildVariants(parentAssetId: string): Promise<MediaAssetRow[]> {
    return this.db
      .select(selectColumns)
      .from(mediaAssets)
      .where(
        and(
          eq(mediaAssets.parentAssetId, parentAssetId),
          eq(mediaAssets.isDeleted, false),
        ),
      );
  }
}
