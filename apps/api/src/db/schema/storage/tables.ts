import {
  bigint,
  boolean,
  index,
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
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
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
  ],
);
