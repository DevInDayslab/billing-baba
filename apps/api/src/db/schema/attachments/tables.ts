import { index, integer, pgTable, text, uuid } from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { syncedBusinessColumns } from '../columns';
import {
  documentAttachmentEntityTypeEnum,
  documentAttachmentKindEnum,
} from '../enums';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const documentAttachments = pgTable(
  'document_attachments',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    entityType: documentAttachmentEntityTypeEnum('entity_type').notNull(),
    entityId: uuid('entity_id').notNull(),
    mediaAssetId: uuid('media_asset_id'),
    fileName: text('file_name').notNull(),
    fileUrl: text('file_url'),
    mimeType: text('mime_type').notNull(),
    attachmentKind: documentAttachmentKindEnum('attachment_kind').notNull(),
    sortOrder: integer('sort_order').notNull().default(0),
    label: text('label'),
  },
  (table) => [
    index('idx_document_attachments_entity').on(
      table.businessId,
      table.entityType,
      table.entityId,
    ),
    index('idx_document_attachments_media_asset').on(table.mediaAssetId),
  ],
);
