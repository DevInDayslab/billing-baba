import {
  index,
  integer,
  jsonb,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { timestamptz, uuidPrimaryKey } from '../columns';
import { partyContactImportStatusEnum } from '../enums';
import { accounts } from '../identity/tables';

export const partyContactImportSessions = pgTable(
  'party_contact_import_sessions',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    createdByAccountId: uuid('created_by_account_id')
      .notNull()
      .references(() => accounts.id),
    token: text('token').notNull(),
    status: partyContactImportStatusEnum('status').notNull().default('pending'),
    expiresAt: timestamptz('expires_at').notNull(),
    openedAt: timestamptz('opened_at'),
    submittedAt: timestamptz('submitted_at'),
    completedAt: timestamptz('completed_at'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_party_contact_import_sessions_token').on(table.token),
    index('idx_party_contact_import_sessions_business').on(table.businessId),
    index('idx_party_contact_import_sessions_status').on(
      table.businessId,
      table.status,
    ),
  ],
);

export const partyContactImportStagingRows = pgTable(
  'party_contact_import_staging_rows',
  {
    id: uuidPrimaryKey(),
    sessionId: uuid('session_id')
      .notNull()
      .references(() => partyContactImportSessions.id, { onDelete: 'cascade' }),
    sortOrder: integer('sort_order').notNull().default(0),
    displayName: text('display_name').notNull(),
    primaryPhone: text('primary_phone').notNull(),
    phones: jsonb('phones').$type<string[]>().notNull().default([]),
    email: text('email'),
    address: text('address'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_party_contact_import_staging_row').on(
      table.sessionId,
      table.displayName,
      table.primaryPhone,
    ),
    index('idx_party_contact_import_staging_session').on(table.sessionId),
  ],
);
