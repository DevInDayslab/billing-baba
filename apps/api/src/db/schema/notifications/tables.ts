import { boolean, date, pgTable, text, uuid } from 'drizzle-orm/pg-core';
import { syncedBusinessColumns, timestamptz } from '../columns';
import { alertTypeEnum, todoPriorityEnum } from '../enums';
import { businesses } from '../business/tables';
import { parties } from '../crm/tables';

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
  partyId: uuid('party_id').references(() => parties.id),
  dueDate: date('due_date'),
  isCompleted: boolean('is_completed').notNull().default(false),
  completedAt: timestamptz('completed_at'),
});
