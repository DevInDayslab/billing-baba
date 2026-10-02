import { boolean, date, jsonb, pgTable, text, uuid } from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { syncedBusinessColumns, timestamptz } from '../columns';
import { parties } from '../crm/tables';
import { alertTypeEnum, todoPriorityEnum } from '../enums';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const alerts = pgTable('alerts', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  alertType: alertTypeEnum('alert_type').notNull(),
  title: text('title').notNull(),
  message: text('message').notNull(),
  referenceId: uuid('reference_id'),
  referenceType: text('reference_type'),
  isRead: boolean('is_read').notNull().default(false),
});

export const todos = pgTable('todos', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  title: text('title').notNull(),
  description: text('description'),
  priority: todoPriorityEnum('priority').notNull().default('medium'),
  category: text('category'),
  partyId: uuid('party_id').references(() => parties.id),
  dueDate: date('due_date'),
  reminderAt: timestamptz('reminder_at'),
  isCompleted: boolean('is_completed').notNull().default(false),
  completedAt: timestamptz('completed_at'),
  isPinned: boolean('is_pinned').notNull().default(false),
  linkedInvoiceId: uuid('linked_invoice_id'),
  linkedPurchaseId: uuid('linked_purchase_id'),
  linkedProductId: uuid('linked_product_id'),
  attachmentIds: jsonb('attachment_ids')
    .$type<string[]>()
    .notNull()
    .default([]),
});
