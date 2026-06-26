import { sql } from 'drizzle-orm';
import {
  boolean,
  date,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { money, syncedBusinessColumns, timestamptz } from '../columns';
import { parties } from '../crm/tables';
import {
  documentStatusEnum,
  paymentModeEnum,
  purchaseDocumentTypeEnum,
  taxTypeEnum,
} from '../enums';
import { items } from '../inventory/tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const expenseCategories = pgTable('expense_categories', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  name: text('name').notNull(),
  isSystem: boolean('is_system').notNull().default(false),
});

export const purchaseDocuments = pgTable(
  'purchase_documents',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    documentType: purchaseDocumentTypeEnum('document_type').notNull(),
    status: documentStatusEnum('status').notNull().default('draft'),
    documentNumber: text('document_number'),
    documentSeries: text('document_series').notNull(),
    partyId: uuid('party_id')
      .notNull()
      .references(() => parties.id),
    subtotal: money('subtotal').notNull().default('0'),
    taxAmount: money('tax_amount').notNull().default('0'),
    totalAmount: money('total_amount').notNull().default('0'),
    documentDate: timestamptz('document_date').notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('uq_purchase_documents_business_series_number')
      .on(table.businessId, table.documentSeries, table.documentNumber)
      .where(sql`${table.documentNumber} IS NOT NULL`),
  ],
);

export const purchaseDocumentLines = pgTable('purchase_document_lines', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  purchaseDocumentId: uuid('purchase_document_id')
    .notNull()
    .references(() => purchaseDocuments.id),
  itemId: uuid('item_id')
    .notNull()
    .references(() => items.id),
  quantity: money('quantity').notNull(),
  unit: text('unit').notNull(),
  unitPrice: money('unit_price').notNull(),
  taxType: taxTypeEnum('tax_type').notNull().default('none'),
  taxRate: money('tax_rate').notNull().default('0'),
  lineTotal: money('line_total').notNull(),
});

export const expenses = pgTable('expenses', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  categoryId: uuid('category_id')
    .notNull()
    .references(() => expenseCategories.id),
  partyId: uuid('party_id').references(() => parties.id),
  amount: money('amount').notNull(),
  description: text('description'),
  expenseDate: date('expense_date').notNull(),
  paymentMode: paymentModeEnum('payment_mode'),
});
