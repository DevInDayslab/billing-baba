import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { generatedDocuments } from '../../db/schema/generated-documents/tables';
import type {
  GeneratedDocumentKind,
  GeneratedDocumentSourceType,
} from './generated-document.constants';
import type { GeneratedDocumentRecord } from './generated-document.types';

function mapRow(row: typeof generatedDocuments.$inferSelect): GeneratedDocumentRecord {
  return {
    id: row.id,
    businessId: row.businessId,
    documentKind: row.documentKind,
    sourceType: row.sourceType,
    sourceId: row.sourceId,
    mediaAssetId: row.mediaAssetId,
    sourceVersion: row.sourceVersion,
    fileName: row.fileName,
    mimeType: row.mimeType,
    publicToken: row.publicToken,
    generatedAt: row.generatedAt,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    createdBy: row.createdBy ?? null,
  };
}

export class GeneratedDocumentRepository {
  constructor(private readonly db: Database) {}

  async findBySource(
    businessId: string,
    documentKind: GeneratedDocumentKind,
    sourceType: GeneratedDocumentSourceType,
    sourceId: string,
  ): Promise<GeneratedDocumentRecord | null> {
    const [row] = await this.db
      .select()
      .from(generatedDocuments)
      .where(
        and(
          eq(generatedDocuments.businessId, businessId),
          eq(generatedDocuments.documentKind, documentKind),
          eq(generatedDocuments.sourceType, sourceType),
          eq(generatedDocuments.sourceId, sourceId),
          eq(generatedDocuments.isDeleted, false),
        ),
      )
      .limit(1);
    return row ? mapRow(row) : null;
  }

  async findById(
    businessId: string,
    id: string,
  ): Promise<GeneratedDocumentRecord | null> {
    const [row] = await this.db
      .select()
      .from(generatedDocuments)
      .where(
        and(
          eq(generatedDocuments.businessId, businessId),
          eq(generatedDocuments.id, id),
          eq(generatedDocuments.isDeleted, false),
        ),
      )
      .limit(1);
    return row ? mapRow(row) : null;
  }

  async findByPublicToken(
    token: string,
  ): Promise<GeneratedDocumentRecord | null> {
    const [row] = await this.db
      .select()
      .from(generatedDocuments)
      .where(
        and(
          eq(generatedDocuments.publicToken, token),
          eq(generatedDocuments.isDeleted, false),
        ),
      )
      .limit(1);
    return row ? mapRow(row) : null;
  }

  async upsert(input: {
    businessId: string;
    documentKind: GeneratedDocumentKind;
    sourceType: GeneratedDocumentSourceType;
    sourceId: string;
    mediaAssetId: string;
    sourceVersion: number;
    fileName: string;
    mimeType: string;
    publicToken: string;
    accountId: string;
  }): Promise<GeneratedDocumentRecord> {
    const existing = await this.findBySource(
      input.businessId,
      input.documentKind,
      input.sourceType,
      input.sourceId,
    );

    if (existing) {
      const [row] = await this.db
        .update(generatedDocuments)
        .set({
          mediaAssetId: input.mediaAssetId,
          sourceVersion: input.sourceVersion,
          fileName: input.fileName,
          mimeType: input.mimeType,
          generatedAt: new Date(),
          updatedAt: new Date(),
          updatedBy: input.accountId,
        })
        .where(eq(generatedDocuments.id, existing.id))
        .returning();
      return mapRow(row!);
    }

    const [row] = await this.db
      .insert(generatedDocuments)
      .values({
        businessId: input.businessId,
        documentKind: input.documentKind,
        sourceType: input.sourceType,
        sourceId: input.sourceId,
        mediaAssetId: input.mediaAssetId,
        sourceVersion: input.sourceVersion,
        fileName: input.fileName,
        mimeType: input.mimeType,
        publicToken: input.publicToken,
        createdBy: input.accountId,
        updatedBy: input.accountId,
      })
      .returning();
    return mapRow(row!);
  }

  async softDelete(businessId: string, id: string): Promise<boolean> {
    const [row] = await this.db
      .update(generatedDocuments)
      .set({
        isDeleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(generatedDocuments.businessId, businessId),
          eq(generatedDocuments.id, id),
          eq(generatedDocuments.isDeleted, false),
        ),
      )
      .returning({ id: generatedDocuments.id });
    return Boolean(row);
  }

  getMediaAssetId(
    businessId: string,
    id: string,
  ): Promise<string | null> {
    return this.findById(businessId, id).then((row) => row?.mediaAssetId ?? null);
  }
}
