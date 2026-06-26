import { boolean, integer, pgTable, text, uniqueIndex, uuid, type AnyPgColumn } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { money, syncedBusinessColumns, timestamptz } from '../columns';
import {
  documentStatusEnum,
  salesDocumentTypeEnum,
  taxTypeEnum,
} from '../enums';
import { businesses } from '../business/tables';
import { parties } from '../crm/tables';
import { items } from '../inventory/tables';
import { users } from '../identity/tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const posSessions = pgTable('pos_sessions', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  userId: uuid('user_id')
    .notNull()
    .references(() => users.id),
  startedAt: timestamptz('started_at').notNull().defaultNow(),
  endedAt: timestamptz('ended_at'),
  openingCash: money('opening_cash'),
  closingCash: money('closing_cash'),
});

export const salesDocuments = pgTable(
  'sales_documents',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    documentType: salesDocumentTypeEnum('document_type').notNull(),
    status: documentStatusEnum('status').notNull().default('draft'),
    documentNumber: text('document_number'),
    documentSeries: text('document_series').notNull(),
    partyId: uuid('party_id').references(() => parties.id),
    isGstFormal: boolean('is_gst_formal').notNull().default(false),
    partyStateCode: text('party_state_code'),
    subtotal: money('subtotal').notNull().default('0'),
    discountTotal: money('discount_total').notNull().default('0'),
    taxAmount: money('tax_amount').notNull().default('0'),
    totalAmount: money('total_amount').notNull().default('0'),
    documentDate: timestamptz('document_date').notNull().defaultNow(),
    convertedFromId: uuid('converted_from_id').references(
      (): AnyPgColumn => salesDocuments.id,
    ),
    posSessionId: uuid('pos_session_id').references(() => posSessions.id),
    notes: text('notes'),
  },
  (table) => [
    uniqueIndex('uq_sales_documents_business_series_number')
      .on(table.businessId, table.documentSeries, table.documentNumber)
      .where(sql`${table.documentNumber} IS NOT NULL`),
  ],
);

export const salesDocumentLines = pgTable('sales_document_lines', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  salesDocumentId: uuid('sales_document_id')
    .notNull()
    .references(() => salesDocuments.id),
  itemId: uuid('item_id')
    .notNull()
    .references(() => items.id),
  quantity: money('quantity').notNull(),
  unit: text('unit').notNull(),
  unitPrice: money('unit_price').notNull(),
  marketPrice: money('market_price'),
  discountAmount: money('discount_amount').notNull().default('0'),
  taxType: taxTypeEnum('tax_type').notNull().default('none'),
  taxRate: money('tax_rate').notNull().default('0'),
  cgstAmount: money('cgst_amount').notNull().default('0'),
  sgstAmount: money('sgst_amount').notNull().default('0'),
  igstAmount: money('igst_amount').notNull().default('0'),
  lineTotal: money('line_total').notNull(),
  sortOrder: integer('sort_order').notNull().default(0),
});
