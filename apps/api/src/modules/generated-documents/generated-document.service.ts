import { randomBytes } from 'node:crypto';
import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { StorageNotFoundError } from '../storage/storage.errors';
import { StorageService } from '../storage/storage.service';
import { MediaAssetRepository } from '../storage/storage.repository';
import {
  GENERATED_DOCUMENT_POLICY,
  GENERATED_MIME_EXTENSIONS,
  MIME_FOR_GENERATED_KIND,
  ownerTypeForGeneratedKind,
  storagePurposeForGeneratedKind,
  type GeneratedDocumentKind,
  type GeneratedDocumentSourceType,
} from './generated-document.constants';
import {
  assertGeneratedKindMatchesSource,
  resolveGeneratedSourceVersion,
} from './generated-document.entity-resolver';
import { toGeneratedDocumentResponse } from './generated-document.mapper';
import { GeneratedDocumentRepository } from './generated-document.repository';
import type {
  GeneratedDocumentResponse,
  PublicGeneratedDocumentResponse,
} from './generated-document.types';

export type GeneratedDocumentServiceDeps = {
  config: AppConfig;
  repository?: GeneratedDocumentRepository;
  storage?: StorageService;
  membership?: Pick<MediaAssetRepository, 'hasBusinessMembership'>;
  resolveSourceVersion?: (
    businessId: string,
    sourceType: GeneratedDocumentSourceType,
    sourceId: string,
  ) => Promise<{ sourceVersion: number }>;
  assertKindMatchesSource?: (
    businessId: string,
    documentKind: GeneratedDocumentKind,
    sourceType: GeneratedDocumentSourceType,
    sourceId: string,
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

function generatePublicToken(): string {
  return randomBytes(32).toString('base64url');
}

function decodeContentBase64(contentBase64: string): Buffer {
  try {
    const buffer = Buffer.from(contentBase64, 'base64');
    if (buffer.length === 0) {
      throw new Error('empty');
    }
    return buffer;
  } catch {
    throw new AppError('VALIDATION_ERROR', 'Invalid content_base64 payload', 400);
  }
}

export class GeneratedDocumentService {
  private readonly repository: GeneratedDocumentRepository;
  private readonly storage: StorageService;
  private readonly membership: Pick<MediaAssetRepository, 'hasBusinessMembership'>;
  private readonly config: AppConfig;
  private readonly resolveSourceVersionFn: NonNullable<
    GeneratedDocumentServiceDeps['resolveSourceVersion']
  >;
  private readonly assertKindMatchesSourceFn: NonNullable<
    GeneratedDocumentServiceDeps['assertKindMatchesSource']
  >;

  constructor(deps: GeneratedDocumentServiceDeps) {
    const db = requireDb();
    this.config = deps.config;
    this.repository =
      deps.repository ?? new GeneratedDocumentRepository(db);
    this.membership =
      deps.membership ?? new MediaAssetRepository(db);
    this.storage =
      deps.storage ??
      new StorageService({
        config: deps.config,
      });
    this.resolveSourceVersionFn =
      deps.resolveSourceVersion ??
      (async (businessId, sourceType, sourceId) => {
        const snapshot = await resolveGeneratedSourceVersion(
          db,
          businessId,
          sourceType,
          sourceId,
        );
        return { sourceVersion: snapshot.sourceVersion };
      });
    this.assertKindMatchesSourceFn =
      deps.assertKindMatchesSource ??
      (async (businessId, documentKind, sourceType, sourceId) => {
        await assertGeneratedKindMatchesSource(
          db,
          businessId,
          documentKind,
          sourceType,
          sourceId,
        );
      });
  }

  async lookup(
    businessId: string,
    accountId: string,
    documentKind: GeneratedDocumentKind,
    sourceType: GeneratedDocumentSourceType,
    sourceId: string,
  ): Promise<GeneratedDocumentResponse | null> {
    await this.assertAccess(businessId, accountId);
    await this.assertKindMatchesSourceFn(
      businessId,
      documentKind,
      sourceType,
      sourceId,
    );

    const current = await this.resolveSourceVersionFn(
      businessId,
      sourceType,
      sourceId,
    );
    const existing = await this.repository.findBySource(
      businessId,
      documentKind,
      sourceType,
      sourceId,
    );

    if (
      !existing?.mediaAssetId ||
      existing.sourceVersion !== current.sourceVersion
    ) {
      return null;
    }

    return this.enrichRow(businessId, accountId, existing, true);
  }

  async ensureStored(
    businessId: string,
    accountId: string,
    input: {
      documentKind: GeneratedDocumentKind;
      sourceType: GeneratedDocumentSourceType;
      sourceId: string;
      fileName: string;
      mimeType: string;
      contentBase64: string;
      forceRegenerate?: boolean;
    },
  ): Promise<GeneratedDocumentResponse> {
    await this.assertAccess(businessId, accountId);
    await this.assertKindMatchesSourceFn(
      businessId,
      input.documentKind,
      input.sourceType,
      input.sourceId,
    );

    const expectedMime = MIME_FOR_GENERATED_KIND[input.documentKind];
    if (input.mimeType !== expectedMime) {
      throw new AppError(
        'VALIDATION_ERROR',
        `mime_type must be ${expectedMime} for ${input.documentKind}`,
        400,
      );
    }

    const current = await this.resolveSourceVersionFn(
      businessId,
      input.sourceType,
      input.sourceId,
    );

    const existing = await this.repository.findBySource(
      businessId,
      input.documentKind,
      input.sourceType,
      input.sourceId,
    );

    if (
      !input.forceRegenerate &&
      existing?.mediaAssetId &&
      existing.sourceVersion === current.sourceVersion
    ) {
      return this.enrichRow(businessId, accountId, existing, true);
    }

    const buffer = decodeContentBase64(input.contentBase64);
    if (buffer.length > GENERATED_DOCUMENT_POLICY.maxBytes) {
      throw new AppError('VALIDATION_ERROR', 'Generated file is too large', 400);
    }

    if (existing?.mediaAssetId) {
      try {
        await this.storage.deleteAsset(
          businessId,
          accountId,
          existing.mediaAssetId,
        );
      } catch (error) {
        if (!(error instanceof StorageNotFoundError)) {
          throw error;
        }
      }
    }

    const asset = await this.storage.storeFromBuffer(businessId, accountId, {
      purpose: storagePurposeForGeneratedKind(input.documentKind),
      visibility: 'private',
      mimeType: input.mimeType,
      buffer,
      ownerType: ownerTypeForGeneratedKind(input.documentKind),
      ownerId: input.sourceId,
      extension: GENERATED_MIME_EXTENSIONS[input.mimeType as keyof typeof GENERATED_MIME_EXTENSIONS],
      policy: GENERATED_DOCUMENT_POLICY,
    });

    const saved = await this.repository.upsert({
      businessId,
      documentKind: input.documentKind,
      sourceType: input.sourceType,
      sourceId: input.sourceId,
      mediaAssetId: asset.id,
      sourceVersion: current.sourceVersion,
      fileName: input.fileName,
      mimeType: input.mimeType,
      publicToken: existing?.publicToken ?? generatePublicToken(),
      accountId,
    });

    return this.enrichRow(businessId, accountId, saved, false);
  }

  async getSignedDownloadUrl(
    businessId: string,
    accountId: string,
    id: string,
  ): Promise<{ download_url: string; expires_at: string | null }> {
    await this.assertAccess(businessId, accountId);
    const row = await this.repository.findById(businessId, id);
    if (!row?.mediaAssetId) {
      throw new AppError('NOT_FOUND', 'Generated document not found', 404);
    }

    const result = await this.storage.getDownloadUrl(
      businessId,
      accountId,
      row.mediaAssetId,
    );
    return {
      download_url: result.url,
      expires_at: result.expiresAt,
    };
  }

  async regenerate(
    businessId: string,
    accountId: string,
    id: string,
    input: {
      fileName: string;
      mimeType: string;
      contentBase64: string;
    },
  ): Promise<GeneratedDocumentResponse> {
    const row = await this.repository.findById(businessId, id);
    if (!row) {
      throw new AppError('NOT_FOUND', 'Generated document not found', 404);
    }

    return this.ensureStored(businessId, accountId, {
      documentKind: row.documentKind,
      sourceType: row.sourceType,
      sourceId: row.sourceId,
      fileName: input.fileName,
      mimeType: input.mimeType,
      contentBase64: input.contentBase64,
      forceRegenerate: true,
    });
  }

  async getPublicDocument(
    token: string,
  ): Promise<PublicGeneratedDocumentResponse> {
    const row = await this.repository.findByPublicToken(token);
    if (!row?.mediaAssetId) {
      throw new AppError('NOT_FOUND', 'Document not found', 404);
    }

    const current = await this.resolveSourceVersionFn(
      row.businessId,
      row.sourceType,
      row.sourceId,
    );
    if (row.sourceVersion !== current.sourceVersion) {
      throw new AppError(
        'DOCUMENT_STALE',
        'This document is outdated. Please regenerate it.',
        410,
      );
    }

    const download = await this.storage.getBusinessAssetDownloadUrl(
      row.businessId,
      row.mediaAssetId,
    );

    return {
      token: row.publicToken,
      document_kind: row.documentKind,
      file_name: row.fileName,
      mime_type: row.mimeType,
      generated_at: row.generatedAt.toISOString(),
      download_url: download.url,
    };
  }

  async getPublicFileRedirectUrl(token: string): Promise<string> {
    const doc = await this.getPublicDocument(token);
    return doc.download_url;
  }

  private async enrichRow(
    businessId: string,
    accountId: string,
    row: Awaited<ReturnType<GeneratedDocumentRepository['findBySource']>> & {},
    cached: boolean,
  ): Promise<GeneratedDocumentResponse> {
    if (!row.mediaAssetId) {
      throw new AppError('NOT_FOUND', 'Generated document file missing', 404);
    }

    const downloadUrl = await this.storage.resolveBusinessAssetUrl(
      businessId,
      accountId,
      row.mediaAssetId,
    );

    const publicUrl = this.buildPublicFileUrl(row.publicToken);

    return toGeneratedDocumentResponse(row, {
      cached,
      downloadUrl,
      publicUrl,
    });
  }

  private buildPublicFileUrl(token: string): string {
    return `${this.config.apiPrefix}/public/generated-documents/${token}/file`;
  }

  private async assertAccess(
    businessId: string,
    accountId: string,
  ): Promise<void> {
    const hasAccess = await this.membership.hasBusinessMembership(
      businessId,
      accountId,
    );
    if (!hasAccess) {
      throw new AppError('FORBIDDEN', 'Business access denied', 403);
    }
  }
}
