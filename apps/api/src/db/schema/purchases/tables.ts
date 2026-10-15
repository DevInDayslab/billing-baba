import { sql } from 'drizzle-orm';
import {
  type AnyPgColumn,
  boolean,
  date,
  integer,
  jsonb,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { money, syncedBusinessColumns, timestamptz } from '../columns';
import { bankAccounts } from '../bank-accounts/tables';
import { parties } from '../crm/tables';
import {
  documentStatusEnum,
  expenseCategoryTypeEnum,
  paymentModeEnum,
  purchaseDocumentTypeEnum,
  purchaseFaStatusEnum,
  taxTypeEnum,
} from '../enums';
import { items } from '../inventory/tables';
import { syncPullIndex } from '../sync-pull-index';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const expenseCategories = pgTable(
  'expense_categories',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    categoryType: expenseCategoryTypeEnum('category_type')
      .notNull()
      .default('direct'),
    isSystem: boolean('is_system').notNull().default(false),
  },
  (table) => [
    uniqueIndex('uq_expense_categories_business_name')
      .on(table.businessId, sql`lower(${table.name})`)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'expense_categories',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const expenseItems = pgTable(
  'expense_items',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    hsnSac: text('hsn_sac'),
    price: money('price').notNull().default('0'),
    priceIsTaxInclusive: boolean('price_is_tax_inclusive')
      .notNull()
      .default(false),
    taxRate: money('tax_rate').notNull().default('0'),
  },
  (table) => [
    uniqueIndex('uq_expense_items_business_name')
      .on(table.businessId, sql`lower(${table.name})`)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'expense_items',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

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
    isGstFormal: boolean('is_gst_formal').notNull().default(false),
    partyStateCode: text('party_state_code'),
    subtotal: money('subtotal').notNull().default('0'),
    discountTotal: money('discount_total').notNull().default('0'),
    taxAmount: money('tax_amount').notNull().default('0'),
    tcsSectionId: uuid('tcs_section_id'),
    tcsRate: money('tcs_rate'),
    tcsBaseAmount: money('tcs_base_amount').default('0'),
    tcsAmount: money('tcs_amount').default('0'),
    totalAmount: money('total_amount').notNull().default('0'),
    documentDate: timestamptz('document_date').notNull().defaultNow(),
    convertedFromId: uuid('converted_from_id').references(
      (): AnyPgColumn => purchaseDocuments.id,
    ),
    originalDocumentId: uuid('original_document_id').references(
      (): AnyPgColumn => purchaseDocuments.id,
    ),
    originalDocumentNumber: text('original_document_number'),
    originalDocumentDate: timestamptz('original_document_date'),
    supplierInvoiceNumber: text('supplier_invoice_number'),
    dueDate: date('due_date'),
    notes: text('notes'),
  },
  (table) => [
    uniqueIndex('uq_purchase_documents_business_series_number')
      .on(table.businessId, table.documentSeries, table.documentNumber)
      .where(sql`${table.documentNumber} IS NOT NULL`),
    syncPullIndex(
      'purchase_documents',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const purchaseDocumentLines = pgTable(
  'purchase_document_lines',
  {
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
    discountAmount: money('discount_amount').notNull().default('0'),
    taxType: taxTypeEnum('tax_type').notNull().default('none'),
    taxRate: money('tax_rate').notNull().default('0'),
    cgstAmount: money('cgst_amount').notNull().default('0'),
    sgstAmount: money('sgst_amount').notNull().default('0'),
    igstAmount: money('igst_amount').notNull().default('0'),
    cessRate: money('cess_rate').notNull().default('0'),
    cessAmount: money('cess_amount').notNull().default('0'),
    lineTotal: money('line_total').notNull(),
    sortOrder: integer('sort_order').notNull().default(0),
  },
  (table) => [
    sql`CHECK (${table.quantity} > 0)`,
    syncPullIndex(
      'purchase_document_lines',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const expenses = pgTable(
  'expenses',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    categoryId: uuid('category_id')
      .notNull()
      .references(() => expenseCategories.id),
    expenseItemId: uuid('expense_item_id').references(() => expenseItems.id),
    partyId: uuid('party_id').references(() => parties.id),
    amount: money('amount').notNull(),
    taxAmount: money('tax_amount').notNull().default('0'),
    taxRate: money('tax_rate').notNull().default('0'),
    description: text('description'),
    notes: text('notes'),
    referenceNumber: text('reference_number'),
    attachments: jsonb('attachments').$type<string[]>().default([]),
    expenseDate: date('expense_date').notNull(),
    paymentMode: paymentModeEnum('payment_mode'),
    bankAccountId: uuid('bank_account_id').references(() => bankAccounts.id),
    sourceReferenceId: uuid('source_reference_id'),
    sourceReferenceType: text('source_reference_type'),
    loyaltyPoints: money('loyalty_points'),
    dueDate: date('due_date'),
    balanceDue: money('balance_due').default('0'),
  },
  (table) => [
    syncPullIndex(
      'expenses',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const purchaseFaBatches = pgTable('purchase_fa_batches', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  partyId: uuid('party_id')
    .notNull()
    .references(() => parties.id),
  referenceNumber: text('reference_number'),
  purchaseDate: date('purchase_date').notNull(),
  dueDate: date('due_date'),
  paymentMode: paymentModeEnum('payment_mode'),
  subtotal: money('subtotal').notNull().default('0'),
  taxAmount: money('tax_amount').notNull().default('0'),
  totalAmount: money('total_amount').notNull().default('0'),
  balanceDue: money('balance_due').notNull().default('0'),
  status: purchaseFaStatusEnum('status').notNull().default('unpaid'),
  notes: text('notes'),
  description: text('description'),
});

export const purchaseFixedAssets = pgTable(
  'purchase_fixed_assets',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    batchId: uuid('batch_id')
      .notNull()
      .references(() => purchaseFaBatches.id),
    purchaseDocumentId: uuid('purchase_document_id').references(
      () => purchaseDocuments.id,
    ),
    assetName: text('asset_name').notNull(),
    assetCategory: text('asset_category'),
    serialNumber: text('serial_number'),
    purchasePrice: money('purchase_price').notNull(),
    location: text('location'),
    warrantyExpiry: date('warranty_expiry'),
    description: text('description'),
    qty: money('qty').notNull().default('1'),
    taxRate: money('tax_rate').notNull().default('0'),
    taxAmount: money('tax_amount').notNull().default('0'),
    lineTotal: money('line_total').notNull(),
    sortOrder: integer('sort_order').notNull().default(0),
  },
  (table) => [
    uniqueIndex('uq_purchase_fixed_assets_business_serial')
      .on(table.businessId, table.serialNumber)
      .where(
        sql`${table.serialNumber} IS NOT NULL AND ${table.isDeleted} = false`,
      ),
  ],
);
