import {
  index,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { timestamptz, uuidPrimaryKey } from '../columns';
import { businesses } from '../business/tables';

/**
 * Durable outbound notification send log for idempotency.
 * Successful rows prevent duplicate WhatsApp sends for the same key.
 */
export const notificationSendLog = pgTable(
  'notification_send_log',
  {
    id: uuidPrimaryKey(),
    idempotencyKey: text('idempotency_key').notNull(),
    notificationType: text('notification_type').notNull(),
    provider: text('provider').notNull(),
    recipientMasked: text('recipient_masked').notNull(),
    companyId: uuid('company_id').references(() => businesses.id),
    status: text('status').notNull(),
    providerMessageId: text('provider_message_id'),
    errorCode: text('error_code'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_notification_send_log_idempotency_key').on(
      table.idempotencyKey,
    ),
    index('idx_notification_send_log_created_at').on(table.createdAt),
    index('idx_notification_send_log_company').on(table.companyId),
  ],
);
