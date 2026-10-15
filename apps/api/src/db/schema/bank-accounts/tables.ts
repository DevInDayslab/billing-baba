import { sql } from 'drizzle-orm';
import {
  boolean,
  date,
  index,
  pgTable,
  smallint,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { parties } from '../crm/tables';
import {
  money,
  syncedBusinessColumns,
  timestamptz,
  uuidPrimaryKey,
} from '../columns';
import {
  accountAdjustmentKindEnum,
  accountMovementDirectionEnum,
  accountMovementTypeEnum,
  bankAccountTypeEnum,
} from '../enums';
import { syncPullIndex } from '../sync-pull-index';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const bankAccounts = pgTable(
  'bank_accounts',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    type: bankAccountTypeEnum('type').notNull(),
    displayName: text('display_name').notNull(),
    bankName: text('bank_name'),
    accountNumber: text('account_number'),
    ifsc: text('ifsc'),
    upiId: text('upi_id'),
    openingBalance: money('opening_balance').notNull().default('0'),
    openingBalanceAsOf: date('opening_balance_as_of').notNull(),
    isDefault: boolean('is_default').notNull().default(false),
    isActive: boolean('is_active').notNull().default(true),
  },
  (table) => [
    uniqueIndex('uq_bank_accounts_one_cash_per_business')
      .on(table.businessId)
      .where(sql`${table.type} = 'cash' AND ${table.isDeleted} = false`),
    uniqueIndex('uq_bank_accounts_one_default_bank')
      .on(table.businessId)
      .where(
        sql`${table.type} = 'bank' AND ${table.isDefault} = true AND ${table.isActive} = true AND ${table.isDeleted} = false`,
      ),
    syncPullIndex(
      'bank_accounts',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

/** Server-authoritative cash/bank ledger lines (not client-synced). */
export const accountMovements = pgTable(
  'account_movements',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    bankAccountId: uuid('bank_account_id')
      .notNull()
      .references(() => bankAccounts.id),
    direction: accountMovementDirectionEnum('direction').notNull(),
    amount: money('amount').notNull(),
    occurredAt: timestamptz('occurred_at').notNull(),
    movementType: accountMovementTypeEnum('movement_type').notNull(),
    referenceType: text('reference_type').notNull(),
    referenceId: uuid('reference_id').notNull(),
    leg: smallint('leg').notNull().default(0),
    partyId: uuid('party_id').references(() => parties.id),
    description: text('description').notNull(),
    referenceNumber: text('reference_number'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    isDeleted: boolean('is_deleted').notNull().default(false),
    deletedAt: timestamptz('deleted_at'),
  },
  (table) => [
    sql`CHECK (${table.amount} > 0)`,
    uniqueIndex('uq_account_movements_source_leg_active')
      .on(table.referenceType, table.referenceId, table.leg)
      .where(sql`${table.isDeleted} = false`),
    index('idx_account_movements_stmt').on(
      table.businessId,
      table.bankAccountId,
      table.occurredAt,
      table.createdAt,
      table.id,
    ),
  ],
);

export const accountTransfers = pgTable('account_transfers', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  fromAccountId: uuid('from_account_id')
    .notNull()
    .references(() => bankAccounts.id),
  toAccountId: uuid('to_account_id')
    .notNull()
    .references(() => bankAccounts.id),
  amount: money('amount').notNull(),
  transferDate: date('transfer_date').notNull(),
  notes: text('notes'),
});

export const accountAdjustments = pgTable('account_adjustments', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  bankAccountId: uuid('bank_account_id')
    .notNull()
    .references(() => bankAccounts.id),
  kind: accountAdjustmentKindEnum('kind').notNull(),
  amount: money('amount').notNull(),
  adjustmentDate: date('adjustment_date').notNull(),
  notes: text('notes'),
});
