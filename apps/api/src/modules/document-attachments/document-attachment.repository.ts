import { and, asc, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { documentAttachments } from '../../db/schema/attachments/tables';
import { AppError } from '../../shared/errors/app-error';
import type { DocumentAttachmentEntityType } from './document-attachment.constants';
import type {
  CreateDocumentAttachmentInput,
  DocumentAttachmentRecord,
} from './document-attachment.types';

export class DocumentAttachmentRepository {
  constructor(private readonly db: Database) {}

  async countByEntity(
    businessId: string,
    entityType: DocumentAttachmentEntityType,
    entityId: string,
  ): Promise<number> {
    const [row] = await this.db
      .select({ count: sql<number>`count(*)::int` })
      .from(documentAttachments)
      .where(
        and(
          eq(documentAttachments.businessId, businessId),
          eq(documentAttachments.entityType, entityType),
          eq(documentAttachments.entityId, entityId),
          eq(documentAttachments.isDeleted, false),
        ),
      );
    return row?.count ?? 0;
  }

  async listByEntity(
    businessId: string,
    entityType: DocumentAttachmentEntityType,
    entityId: string,
  ): Promise<DocumentAttachmentRecord[]> {
    const rows = await this.db
      .select()
      .from(documentAttachments)
      .where(
        and(
          eq(documentAttachments.businessId, businessId),
          eq(documentAttachments.entityType, entityType),
          eq(documentAttachments.entityId, entityId),
          eq(documentAttachments.isDeleted, false),
        ),
      )
      .orderBy(asc(documentAttachments.sortOrder), asc(documentAttachments.createdAt));

    return rows.map(toRecord);
  }

  async findById(
    businessId: string,
    id: string,
  ): Promise<DocumentAttachmentRecord | null> {
    const [row] = await this.db
      .select()
      .from(documentAttachments)
      .where(
        and(
          eq(documentAttachments.businessId, businessId),
          eq(documentAttachments.id, id),
          eq(documentAttachments.isDeleted, false),
        ),
      )
      .limit(1);
    return row ? toRecord(row) : null;
  }

  async getMediaAssetId(
    businessId: string,
    id: string,
  ): Promise<string | null> {
    const row = await this.findById(businessId, id);
    return row?.media_asset_id ?? null;
  }

  async insert(
    businessId: string,
    entityType: DocumentAttachmentEntityType,
    entityId: string,
    input: CreateDocumentAttachmentInput,
  ): Promise<DocumentAttachmentRecord> {
    const [row] = await this.db
      .insert(documentAttachments)
      .values({
        businessId,
        entityType,
        entityId,
        mediaAssetId: input.mediaAssetId,
        fileName: input.fileName,
        fileUrl: input.fileUrl,
        mimeType: input.mimeType,
        attachmentKind: input.attachmentKind,
        sortOrder: input.sortOrder ?? 0,
        label: input.label ?? null,
        createdBy: input.createdBy ?? null,
        updatedBy: input.updatedBy ?? null,
      })
      .returning();
    if (!row) {
      throw new AppError('INTERNAL_ERROR', 'Failed to create attachment', 500);
    }
    return toRecord(row);
  }

  async updateMetadata(
    businessId: string,
    id: string,
    patch: {
      fileName?: string;
      label?: string | null;
      updatedBy?: string | null;
    },
  ): Promise<DocumentAttachmentRecord | null> {
    const [row] = await this.db
      .update(documentAttachments)
      .set({
        ...(patch.fileName !== undefined ? { fileName: patch.fileName } : {}),
        ...(patch.label !== undefined ? { label: patch.label } : {}),
        ...(patch.updatedBy !== undefined ? { updatedBy: patch.updatedBy } : {}),
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(documentAttachments.businessId, businessId),
          eq(documentAttachments.id, id),
          eq(documentAttachments.isDeleted, false),
        ),
      )
      .returning();
    return row ? toRecord(row) : null;
  }

  async softDelete(
    businessId: string,
    id: string,
    userId?: string | null,
  ): Promise<boolean> {
    const now = new Date();
    const result = await this.db
      .update(documentAttachments)
      .set({
        isDeleted: true,
        deletedAt: now,
        updatedAt: now,
        updatedBy: userId ?? null,
      })
      .where(
        and(
          eq(documentAttachments.businessId, businessId),
          eq(documentAttachments.id, id),
          eq(documentAttachments.isDeleted, false),
        ),
      )
      .returning({ id: documentAttachments.id });
    return result.length > 0;
  }
}

function toRecord(row: typeof documentAttachments.$inferSelect): DocumentAttachmentRecord {
  return {
    id: row.id,
    business_id: row.businessId,
    entity_type: row.entityType,
    entity_id: row.entityId,
    media_asset_id: row.mediaAssetId,
    file_name: row.fileName,
    file_url: row.fileUrl,
    mime_type: row.mimeType,
    attachment_kind: row.attachmentKind,
    sort_order: row.sortOrder,
    label: row.label,
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
