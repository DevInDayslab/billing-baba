import { sql } from 'drizzle-orm';
import {
  type AnyPgColumn,
  boolean,
  date,
  integer,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { syncPullIndex } from '../sync-pull-index';
import { businesses } from '../business/tables';
import { money, syncedBusinessColumns, timestamptz } from '../columns';
import { parties } from '../crm/tables';
import {
  documentStatusEnum,
  paymentModeEnum,
  saleFaStatusEnum,
  salesDocumentTypeEnum,
  taxTypeEnum,
} from '../enums';
import { users } from '../identity/tables';
import { items } from '../inventory/tables';
import { purchaseFixedAssets } from '../purchases/tables';

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
    syncPullIndex(
      'sales_documents',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const salesDocumentLines = pgTable(
  'sales_document_lines',
  {
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
  },
  (table) => [
    sql`CHECK (${table.quantity} > 0)`,
    syncPullIndex(
      'sales_document_lines',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const saleFaBatches = pgTable('sale_fa_batches', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  partyId: uuid('party_id')
    .notNull()
    .references(() => parties.id),
  referenceNumber: text('reference_number'),
  saleDate: date('sale_date').notNull(),
  dueDate: date('due_date'),
  paymentMode: paymentModeEnum('payment_mode'),
  subtotal: money('subtotal').notNull().default('0'),
  taxAmount: money('tax_amount').notNull().default('0'),
  totalAmount: money('total_amount').notNull().default('0'),
  balanceDue: money('balance_due').notNull().default('0'),
  status: saleFaStatusEnum('status').notNull().default('unpaid'),
  notes: text('notes'),
  description: text('description'),
});

export const saleFixedAssets = pgTable(
  'sale_fixed_assets',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    batchId: uuid('batch_id')
      .notNull()
      .references(() => saleFaBatches.id),
    purchaseFixedAssetId: uuid('purchase_fixed_asset_id').references(
      () => purchaseFixedAssets.id,
    ),
    assetName: text('asset_name').notNull(),
    itemCode: text('item_code'),
    assetCategory: text('asset_category'),
    serialNumber: text('serial_number'),
    salePrice: money('sale_price').notNull(),
    location: text('location'),
    description: text('description'),
    qty: money('qty').notNull().default('1'),
    taxRate: money('tax_rate').notNull().default('0'),
    taxAmount: money('tax_amount').notNull().default('0'),
    lineTotal: money('line_total').notNull(),
    sortOrder: integer('sort_order').notNull().default(0),
  },
  (table) => [
    uniqueIndex('uq_sale_fixed_assets_business_serial')
      .on(table.businessId, table.serialNumber)
      .where(
        sql`${table.serialNumber} IS NOT NULL AND ${table.isDeleted} = false`,
      ),
  ],
);
