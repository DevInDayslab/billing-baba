import {
  bigint,
  boolean,
  index,
  integer,
  numeric,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { timestamptz, uuidPrimaryKey } from '../columns';
import { accounts } from '../identity/tables';

/**
 * Server-owned object storage registry.
 * Binary objects live in S3; this table stores metadata only.
 */
export const mediaAssets = pgTable(
  'media_assets',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id').references(() => businesses.id),
    storageKey: text('storage_key').notNull(),
    bucket: text('bucket').notNull(),
    purpose: text('purpose').notNull(),
    visibility: text('visibility').notNull(),
    mimeType: text('mime_type').notNull(),
    fileSize: bigint('file_size', { mode: 'number' }).notNull(),
    etag: text('etag'),
    checksum: text('checksum'),
    ownerType: text('owner_type'),
    ownerId: uuid('owner_id'),
    status: text('status').notNull().default('pending'),
    uploadedBy: uuid('uploaded_by').references(() => accounts.id),
    width: integer('width'),
    height: integer('height'),
    format: text('format'),
    variantType: text('variant_type'),
    parentAssetId: uuid('parent_asset_id'),
    originalSize: bigint('original_size', { mode: 'number' }),
    optimizedSize: bigint('optimized_size', { mode: 'number' }),
    compressionRatio: numeric('compression_ratio', {
      precision: 8,
      scale: 4,
      mode: 'number',
    }),
    processedAt: timestamptz('processed_at'),
    processingStatus: text('processing_status').notNull().default('pending'),
    stagingStorageKey: text('staging_storage_key'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
    deletedAt: timestamptz('deleted_at'),
    isDeleted: boolean('is_deleted').notNull().default(false),
  },
  (table) => [
    uniqueIndex('uq_media_assets_storage_key').on(table.storageKey),
    index('idx_media_assets_business').on(table.businessId),
    index('idx_media_assets_owner').on(table.ownerType, table.ownerId),
    index('idx_media_assets_purpose').on(table.businessId, table.purpose),
    index('idx_media_assets_parent').on(table.parentAssetId),
    index('idx_media_assets_processing_status').on(table.processingStatus),
  ],
);
