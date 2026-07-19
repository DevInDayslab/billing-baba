import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { StorageNotFoundError } from '../storage/storage.errors';
import { StorageService } from '../storage/storage.service';
import { MediaAssetRepository } from '../storage/storage.repository';
import type { UploadIntent } from '../storage/storage.types';
import {
  attachmentKindFromMime,
  DOCUMENT_ATTACHMENT_POLICY,
  MAX_DOCUMENT_ATTACHMENTS,
  storagePurposeForEntity,
  type DocumentAttachmentEntityType,
} from './document-attachment.constants';
import { assertAttachmentEntityExists } from './document-attachment.entity-resolver';
import { DocumentAttachmentRepository } from './document-attachment.repository';
import type {
  DocumentAttachmentRecord,
  DocumentAttachmentResponse,
} from './document-attachment.types';

export type DocumentAttachmentServiceDeps = {
  config: AppConfig;
  repository?: DocumentAttachmentRepository;
  storage?: StorageService;
  membership?: Pick<MediaAssetRepository, 'hasBusinessMembership'>;
  assertEntityExists?: (
    businessId: string,
    entityType: DocumentAttachmentEntityType,
    entityId: string,
  ) => Promise<void>;
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

export class DocumentAttachmentService {
  private readonly repository: DocumentAttachmentRepository;
  private readonly storage: StorageService;
  private readonly membership: Pick<MediaAssetRepository, 'hasBusinessMembership'>;
  private readonly assertEntityExistsFn: DocumentAttachmentServiceDeps['assertEntityExists'];

  constructor(deps: DocumentAttachmentServiceDeps) {
    const db = requireDb();
    this.repository =
      deps.repository ?? new DocumentAttachmentRepository(db);
    this.membership =
      deps.membership ??
      new MediaAssetRepository(db);
    this.assertEntityExistsFn =
      deps.assertEntityExists ??
      (async (businessId, entityType, entityId) => {
        await assertAttachmentEntityExists(
          db,
          businessId,
          entityType,
          entityId,
        );
      });
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });
  }

  async listAttachments(
    businessId: string,
    accountId: string,
    entityType: DocumentAttachmentEntityType,
    entityId: string,
  ): Promise<DocumentAttachmentResponse[]> {
    await this.assertAccess(businessId, accountId, entityType, entityId);
    const rows = await this.repository.listByEntity(
      businessId,
      entityType,
      entityId,
    );
    return this.enrichRows(businessId, accountId, rows);
  }

  async createUploadIntent(
    businessId: string,
    accountId: string,
    entityType: DocumentAttachmentEntityType,
    entityId: string,
    mimeType: string,
    fileSize: number,
    checksum?: string | null,
  ): Promise<UploadIntent> {
    await this.assertAccess(businessId, accountId, entityType, entityId);

    const count = await this.repository.countByEntity(
      businessId,
      entityType,
      entityId,
    );
    if (count >= MAX_DOCUMENT_ATTACHMENTS) {
      throw new AppError(
        'VALIDATION_ERROR',
        `Maximum ${MAX_DOCUMENT_ATTACHMENTS} attachments allowed per transaction`,
        400,
        { file_size: ['Attachment limit reached'] },
      );
    }

    const purpose = storagePurposeForEntity(entityType);

    return this.storage.createUploadIntent(
      businessId,
      accountId,
      {
        purpose,
        visibility: 'authenticated',
        mimeType,
        fileSize,
        ownerType: entityType,
        ownerId: entityId,
        checksum,
      },
      DOCUMENT_ATTACHMENT_POLICY,
    );
  }

  async completeUpload(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    entityType: DocumentAttachmentEntityType,
    entityId: string,
    intentId: string,
    options: {
      fileName: string;
      label?: string | null;
      sortOrder?: number;
      replacesAttachmentId?: string | null;
    },
  ): Promise<DocumentAttachmentResponse> {
    await this.assertAccess(businessId, accountId, entityType, entityId);

    const asset = await this.storage.completeUpload(
      businessId,
      accountId,
      intentId,
    );

    const expectedPurpose = storagePurposeForEntity(entityType);
    if (asset.purpose !== expectedPurpose || asset.ownerType !== entityType) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Upload intent does not match transaction attachment',
        400,
      );
    }

    const url = await this.storage.resolveBusinessAssetUrl(
      businessId,
      accountId,
      asset.id,
    );

    const existingCount = await this.repository.countByEntity(
      businessId,
      entityType,
      entityId,
    );

    const attachment = await this.repository.insert(
      businessId,
      entityType,
      entityId,
      {
        mediaAssetId: asset.id,
        fileName: options.fileName,
        fileUrl: url,
        mimeType: asset.mimeType,
        attachmentKind: attachmentKindFromMime(asset.mimeType),
        sortOrder: options.sortOrder ?? existingCount,
        label: options.label ?? null,
        createdBy: userId ?? null,
        updatedBy: userId ?? null,
      },
    );

    if (options.replacesAttachmentId) {
      await this.deleteAttachment(
        businessId,
        accountId,
        userId,
        options.replacesAttachmentId,
        { skipNotFound: true },
      );
    }

    const [enriched] = await this.enrichRows(businessId, accountId, [
      attachment,
    ]);
    if (!enriched) {
      throw new AppError('INTERNAL_ERROR', 'Failed to enrich attachment', 500);
    }
    return enriched;
  }

  async deleteAttachment(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    attachmentId: string,
    options: { skipNotFound?: boolean } = {},
  ): Promise<void> {
    const row = await this.repository.findById(businessId, attachmentId);
    if (!row) {
      if (options.skipNotFound) return;
      throw new AppError('NOT_FOUND', 'Attachment not found', 404);
    }

    await this.assertAccess(
      businessId,
      accountId,
      row.entity_type,
      row.entity_id,
    );

    const mediaAssetId = row.media_asset_id;
    const deleted = await this.repository.softDelete(
      businessId,
      attachmentId,
      userId ?? null,
    );

    if (!deleted) {
      if (options.skipNotFound) return;
      throw new AppError('NOT_FOUND', 'Attachment not found', 404);
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

  async getDownloadUrl(
    businessId: string,
    accountId: string,
    attachmentId: string,
  ): Promise<{ download_url: string; mime_type: string; file_name: string }> {
    const row = await this.repository.findById(businessId, attachmentId);
    if (!row) {
      throw new AppError('NOT_FOUND', 'Attachment not found', 404);
    }

    await this.assertAccess(
      businessId,
      accountId,
      row.entity_type,
      row.entity_id,
    );

    if (!row.media_asset_id) {
      throw new AppError('NOT_FOUND', 'Attachment file not available', 404);
    }

    const downloadUrl = await this.storage.resolveBusinessAssetUrl(
      businessId,
      accountId,
      row.media_asset_id,
    );

    return {
      download_url: downloadUrl,
      mime_type: row.mime_type,
      file_name: row.file_name,
    };
  }

  async updateMetadata(
    businessId: string,
    accountId: string,
    userId: string | undefined,
    attachmentId: string,
    patch: { fileName?: string; label?: string | null },
  ): Promise<DocumentAttachmentResponse> {
    const row = await this.repository.findById(businessId, attachmentId);
    if (!row) {
      throw new AppError('NOT_FOUND', 'Attachment not found', 404);
    }

    await this.assertAccess(
      businessId,
      accountId,
      row.entity_type,
      row.entity_id,
    );

    const updated = await this.repository.updateMetadata(
      businessId,
      attachmentId,
      {
        fileName: patch.fileName,
        label: patch.label,
        updatedBy: userId ?? null,
      },
    );

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Attachment not found', 404);
    }

    const [enriched] = await this.enrichRows(businessId, accountId, [updated]);
    if (!enriched) {
      throw new AppError('INTERNAL_ERROR', 'Failed to enrich attachment', 500);
    }
    return enriched;
  }

  private async enrichRows(
    businessId: string,
    accountId: string,
    rows: DocumentAttachmentRecord[],
  ): Promise<DocumentAttachmentResponse[]> {
    return Promise.all(
      rows.map(async (row) => {
        if (!row.media_asset_id) {
          return { ...row, download_url: row.file_url };
        }

        try {
          const downloadUrl = await this.storage.resolveBusinessAssetUrl(
            businessId,
            accountId,
            row.media_asset_id,
          );
          return {
            ...row,
            file_url: downloadUrl,
            download_url: downloadUrl,
          };
        } catch {
          return { ...row, download_url: row.file_url };
        }
      }),
    );
  }

  private async assertAccess(
    businessId: string,
    accountId: string,
    entityType: DocumentAttachmentEntityType,
    entityId: string,
  ): Promise<void> {
    const hasAccess = await this.membership.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!hasAccess) {
      throw new AppError('FORBIDDEN', 'Business access denied', 403);
    }
    await this.assertEntityExistsFn!(businessId, entityType, entityId);
  }
}
