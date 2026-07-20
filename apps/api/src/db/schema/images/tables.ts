import {
  bigint,
  boolean,
  index,
  integer,
  numeric,
  pgEnum,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { businesses } from '../business/tables';
import { timestamptz, uuidPrimaryKey } from '../columns';
import { mediaAssets } from '../storage/tables';

export const mediaImageVariantEnum = pgEnum('media_image_variant', [
  'thumbnail',
  'medium',
  'original',
]);

export const mediaImageVariants = pgTable(
  'media_image_variants',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id').references(() => businesses.id),
    sourceMediaAssetId: uuid('source_media_asset_id')
      .notNull()
      .references(() => mediaAssets.id),
    variant: mediaImageVariantEnum('variant').notNull(),
    mediaAssetId: uuid('media_asset_id')
      .notNull()
      .references(() => mediaAssets.id),
    width: integer('width').notNull(),
    height: integer('height').notNull(),
    fileSize: bigint('file_size', { mode: 'number' }).notNull(),
    mimeType: text('mime_type').notNull().default('image/webp'),
    processingDurationMs: integer('processing_duration_ms'),
    compressionRatio: numeric('compression_ratio', { precision: 8, scale: 4 }),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
    deletedAt: timestamptz('deleted_at'),
    isDeleted: boolean('is_deleted').notNull().default(false),
  },
  (table) => [
    uniqueIndex('uq_media_image_variants_source_variant')
      .on(table.sourceMediaAssetId, table.variant)
      .where(sql`${table.isDeleted} = false`),
    index('idx_media_image_variants_business').on(table.businessId),
    index('idx_media_image_variants_source').on(table.sourceMediaAssetId),
  ],
);
