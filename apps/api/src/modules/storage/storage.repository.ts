import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { mediaAssets } from '../../db/schema/storage/tables';
import { BusinessMembershipRepository } from '../../shared/repositories/business-membership.repository';
import type { MediaAssetRow } from './storage.types';

export type InsertMediaAssetValues = {
  id: string;
  businessId: string;
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
};

export type MarkReadyValues = {
  etag: string | null;
  fileSize: number;
  mimeType?: string;
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
}
