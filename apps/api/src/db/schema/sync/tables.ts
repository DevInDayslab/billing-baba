import {
  boolean,
  jsonb,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { money, syncedBusinessColumns, timestamptz } from '../columns';
import { parties } from '../crm/tables';
import { onlineOrderStatusEnum } from '../enums';
import { salesDocuments } from '../sales/tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const onlineOrders = pgTable(
  'online_orders',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    externalOrderId: text('external_order_id').notNull(),
    partyId: uuid('party_id').references(() => parties.id),
    status: onlineOrderStatusEnum('status').notNull().default('pending'),
    totalAmount: money('total_amount').notNull(),
    orderPayload: jsonb('order_payload').notNull(),
    salesDocumentId: uuid('sales_document_id').references(
      () => salesDocuments.id,
    ),
    receivedAt: timestamptz('received_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_online_orders_business_external').on(
      table.businessId,
      table.externalOrderId,
    ),
  ],
);

/** Idempotent push acknowledgements for sync command_id replay. */
export const syncCommandAcks = pgTable(
  'sync_command_acks',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    commandId: uuid('command_id').notNull(),
    command: text('command').notNull(),
    requestHash: text('request_hash').notNull(),
    resultJson: jsonb('result_json').notNull(),
    deviceId: uuid('device_id'),
    processedAt: timestamptz('processed_at').notNull().defaultNow(),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_sync_command_acks_business_command').on(
      table.businessId,
      table.commandId,
    ),
  ],
);

/** Idempotent push acknowledgements for sync mutation_id replay. */
export const syncMutationAcks = pgTable(
  'sync_mutation_acks',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    mutationId: uuid('mutation_id').notNull(),
    kind: text('kind').notNull(),
    resultJson: jsonb('result_json').notNull(),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_sync_mutation_acks_business_mutation').on(
      table.businessId,
      table.mutationId,
    ),
  ],
);
