import { sql } from 'drizzle-orm';
import { date, pgTable, text, uuid } from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import {
  money,
  syncedBusinessColumns,
  timestamptz,
  uuidPrimaryKey,
} from '../columns';
import { parties } from '../crm/tables';
import {
  ledgerEntryTypeEnum,
  paymentDirectionEnum,
  paymentModeEnum,
  paymentSourceEnum,
  shortPaymentHandlingEnum,
} from '../enums';
import { purchaseDocuments } from '../purchases/tables';
import { salesDocuments } from '../sales/tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

/** Immutable double-entry ledger rows */
export const ledgerEntries = pgTable(
  'ledger_entries',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    partyId: uuid('party_id').references(() => parties.id),
    entryType: ledgerEntryTypeEnum('entry_type').notNull(),
    debit: money('debit').notNull().default('0'),
    credit: money('credit').notNull().default('0'),
    balanceAfter: money('balance_after').notNull(),
    referenceId: uuid('reference_id'),
    referenceType: text('reference_type'),
    entryDate: date('entry_date').notNull(),
    description: text('description'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
  },
  (table) => [
    sql`CHECK ((${table.debit} = 0 AND ${table.credit} > 0) OR (${table.credit} = 0 AND ${table.debit} > 0))`,
    sql`CHECK (${table.debit} >= 0)`,
    sql`CHECK (${table.credit} >= 0)`,
  ],
);

export const payments = pgTable('payments', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  partyId: uuid('party_id')
    .notNull()
    .references(() => parties.id),
  direction: paymentDirectionEnum('direction').notNull(),
  amount: money('amount').notNull(),
  paymentMode: paymentModeEnum('payment_mode').notNull(),
  paymentDate: timestamptz('payment_date').notNull().defaultNow(),
  source: paymentSourceEnum('source').notNull().default('manual'),
  referenceNumber: text('reference_number'),
  notes: text('notes'),
  discountAmount: money('discount_amount').notNull().default('0'),
  shortPaymentHandling: shortPaymentHandlingEnum('short_payment_handling'),
});

export const paymentAllocations = pgTable(
  'payment_allocations',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    paymentId: uuid('payment_id')
      .notNull()
      .references(() => payments.id),
    salesDocumentId: uuid('sales_document_id').references(
      () => salesDocuments.id,
    ),
    purchaseDocumentId: uuid('purchase_document_id').references(
      () => purchaseDocuments.id,
    ),
    allocatedAmount: money('allocated_amount').notNull(),
  },
  (table) => [
    sql`CHECK (
      (${table.salesDocumentId} IS NOT NULL AND ${table.purchaseDocumentId} IS NULL) OR
      (${table.salesDocumentId} IS NULL AND ${table.purchaseDocumentId} IS NOT NULL)
    )`,
  ],
);
