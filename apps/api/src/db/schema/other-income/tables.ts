import { sql } from 'drizzle-orm';
import {
  boolean,
  date,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { bankAccounts } from '../bank-accounts/tables';
import { businesses } from '../business/tables';
import { money, syncedBusinessColumns } from '../columns';
import { expenseCategoryTypeEnum, paymentModeEnum } from '../enums';
import { syncPullIndex } from '../sync-pull-index';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const incomeCategories = pgTable(
  'income_categories',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    categoryType: expenseCategoryTypeEnum('category_type')
      .notNull()
      .default('indirect'),
    isSystem: boolean('is_system').notNull().default(false),
  },
  (table) => [
    uniqueIndex('uq_income_categories_business_name')
      .on(table.businessId, sql`lower(${table.name})`)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'income_categories',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const incomeItems = pgTable(
  'income_items',
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
    uniqueIndex('uq_income_items_business_name')
      .on(table.businessId, sql`lower(${table.name})`)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'income_items',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const otherIncomes = pgTable(
  'other_incomes',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    categoryId: uuid('category_id')
      .notNull()
      .references(() => incomeCategories.id),
    incomeItemId: uuid('income_item_id').references(() => incomeItems.id),
    amount: money('amount').notNull(),
    quantity: money('quantity'),
    taxAmount: money('tax_amount').notNull().default('0'),
    taxRate: money('tax_rate').notNull().default('0'),
    description: text('description'),
    notes: text('notes'),
    referenceNumber: text('reference_number'),
    incomeDate: date('income_date').notNull(),
    paymentMode: paymentModeEnum('payment_mode'),
    bankAccountId: uuid('bank_account_id').references(() => bankAccounts.id),
    dueDate: date('due_date'),
    balanceDue: money('balance_due').default('0'),
  },
  (table) => [
    syncPullIndex(
      'other_incomes',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);
