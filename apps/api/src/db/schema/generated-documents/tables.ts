import { sql } from 'drizzle-orm';
import {
  boolean,
  index,
  integer,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { timestamptz, uuidPrimaryKey } from '../columns';
import {
  generatedDocumentKindEnum,
  generatedDocumentSourceTypeEnum,
} from '../enums';

export const generatedDocuments = pgTable(
  'generated_documents',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    documentKind: generatedDocumentKindEnum('document_kind').notNull(),
    sourceType: generatedDocumentSourceTypeEnum('source_type').notNull(),
    sourceId: uuid('source_id').notNull(),
    mediaAssetId: uuid('media_asset_id'),
    sourceVersion: integer('source_version').notNull(),
    fileName: text('file_name').notNull(),
    mimeType: text('mime_type').notNull(),
    publicToken: text('public_token').notNull(),
    generatedAt: timestamptz('generated_at').notNull().defaultNow(),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
    deletedAt: timestamptz('deleted_at'),
    isDeleted: boolean('is_deleted').notNull().default(false),
    createdBy: uuid('created_by'),
    updatedBy: uuid('updated_by'),
    syncVersion: integer('sync_version').notNull().default(1),
    deviceId: uuid('device_id'),
  },
  (table) => [
    uniqueIndex('uq_generated_documents_public_token').on(table.publicToken),
    uniqueIndex('uq_generated_documents_source')
      .on(
        table.businessId,
        table.documentKind,
        table.sourceType,
        table.sourceId,
      )
      .where(sql`${table.isDeleted} = false`),
    index('idx_generated_documents_source').on(
      table.businessId,
      table.sourceType,
      table.sourceId,
    ),
  ],
);
