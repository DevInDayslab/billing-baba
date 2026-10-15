import { sql } from 'drizzle-orm';
import { boolean, date, pgTable, text, uniqueIndex, uuid } from 'drizzle-orm/pg-core';
import { bankAccounts } from '../bank-accounts/tables';
import { businesses } from '../business/tables';
import { parties } from '../crm/tables';
import { money, syncedBusinessColumns, timestamptz } from '../columns';
import {
  taxDepositKindEnum,
  withholdingApplicableOnEnum,
  withholdingTaxDirectionEnum,
  withholdingTaxKindEnum,
} from '../enums';
import { syncPullIndex } from '../sync-pull-index';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const withholdingTaxSections = pgTable(
  'withholding_tax_sections',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    kind: withholdingTaxKindEnum('kind').notNull(),
    code: text('code').notNull(),
    description: text('description').notNull(),
    rate: money('rate').notNull(),
    applicableOn: withholdingApplicableOnEnum('applicable_on').notNull(),
    isActive: boolean('is_active').notNull().default(true),
    isPreloaded: boolean('is_preloaded').notNull().default(false),
  },
  (table) => [
    uniqueIndex('uq_withholding_sections_business_code_on')
      .on(table.businessId, table.code, table.applicableOn)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'withholding_tax_sections',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const taxDeposits = pgTable(
  'tax_deposits',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    kind: taxDepositKindEnum('kind').notNull(),
    bsrCode: text('bsr_code').notNull(),
    challanSerial: text('challan_serial').notNull(),
    depositDate: date('deposit_date').notNull(),
    amount: money('amount').notNull(),
    bankAccountId: uuid('bank_account_id').references(() => bankAccounts.id),
    notes: text('notes'),
  },
  (table) => [
    syncPullIndex(
      'tax_deposits',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const withholdingTaxEntries = pgTable(
  'withholding_tax_entries',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    kind: withholdingTaxKindEnum('kind').notNull(),
    direction: withholdingTaxDirectionEnum('direction').notNull(),
    sectionId: uuid('section_id').references(() => withholdingTaxSections.id),
    sectionCode: text('section_code').notNull(),
    rate: money('rate').notNull(),
    baseAmount: money('base_amount').notNull(),
    taxAmount: money('tax_amount').notNull(),
    partyId: uuid('party_id').references(() => parties.id),
    partyPan: text('party_pan'),
    partyName: text('party_name'),
    sourceType: text('source_type').notNull(),
    sourceId: uuid('source_id').notNull(),
    entryDate: timestamptz('entry_date').notNull(),
    depositId: uuid('deposit_id').references(() => taxDeposits.id),
    certificateNo: text('certificate_no'),
    certificateDate: date('certificate_date'),
  },
  (table) => [
    syncPullIndex(
      'withholding_tax_entries',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);
