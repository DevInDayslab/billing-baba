import { jsonb, pgTable, text, uniqueIndex, uuid } from 'drizzle-orm/pg-core';
import { money, syncedBusinessColumns, timestamptz } from '../columns';
import { onlineOrderStatusEnum } from '../enums';
import { businesses } from '../business/tables';
import { parties } from '../crm/tables';
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
    salesDocumentId: uuid('sales_document_id').references(() => salesDocuments.id),
    receivedAt: timestamptz('received_at').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_online_orders_business_external').on(
      table.businessId,
      table.externalOrderId,
    ),
  ],
);
