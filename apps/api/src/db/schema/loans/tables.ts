import { sql } from 'drizzle-orm';
import {
  date,
  integer,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { bankAccounts } from '../bank-accounts/tables';
import { businesses } from '../business/tables';
import { money, syncedBusinessColumns } from '../columns';
import { loanTransactionTypeEnum } from '../enums';
import { syncPullIndex } from '../sync-pull-index';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const loanAccounts = pgTable(
  'loan_accounts',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    lenderName: text('lender_name'),
    accountNumber: text('account_number'),
    description: text('description'),
    openingOutstanding: money('opening_outstanding').notNull().default('0'),
    openingBalanceAsOf: date('opening_balance_as_of').notNull(),
    interestRate: money('interest_rate'),
    termMonths: integer('term_months'),
    receivedBankAccountId: uuid('received_bank_account_id').references(
      () => bankAccounts.id,
    ),
  },
  (table) => [
    uniqueIndex('uq_loan_accounts_business_name')
      .on(table.businessId, sql`lower(${table.name})`)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'loan_accounts',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const loanTransactions = pgTable(
  'loan_transactions',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    loanAccountId: uuid('loan_account_id')
      .notNull()
      .references(() => loanAccounts.id),
    transactionType: loanTransactionTypeEnum('transaction_type').notNull(),
    transactionDate: date('transaction_date').notNull(),
    principalAmount: money('principal_amount').notNull().default('0'),
    interestAmount: money('interest_amount').notNull().default('0'),
    chargesAmount: money('charges_amount').notNull().default('0'),
    bankAccountId: uuid('bank_account_id')
      .notNull()
      .references(() => bankAccounts.id),
    description: text('description'),
    referenceNumber: text('reference_number'),
  },
  (table) => [
    syncPullIndex(
      'loan_transactions',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);
