import { sql } from 'drizzle-orm';
import {
  boolean,
  date,
  integer,
  numeric,
  pgTable,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { syncPullIndex } from '../sync-pull-index';
import { businesses } from '../business/tables';
import {
  money,
  syncedBusinessColumns,
  timestamptz,
  uuidPrimaryKey,
} from '../columns';
import {
  contactActivityTypeEnum,
  dealStageEnum,
  hiddenLedgerEntryStatusEnum,
  leadActivityTypeEnum,
  leadSourceEnum,
  leadStatusEnum,
  loyaltyTransactionTypeEnum,
  partyCategoryEnum,
  partyTypeEnum,
  pricingTierEnum,
  visitPurposeEnum,
} from '../enums';
import { users } from '../identity/tables';
import { salesDocuments } from '../sales/tables';
import { areas } from '../settings/tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const parties = pgTable(
  'parties',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    legalName: text('legal_name'),
    alias: text('alias'),
    mobile: text('mobile'),
    email: text('email'),
    partyGroup: text('party_group'),
    areaCode: text('area_code'),
    partyType: partyTypeEnum('party_type').notNull().default('customer'),
    partyCategory: partyCategoryEnum('party_category'),
    pricingTier: pricingTierEnum('pricing_tier').notNull().default('tier_1'),
    gstin: text('gstin'),
    stateCode: text('state_code'),
    areaId: uuid('area_id').references(() => areas.id),
    creditLimit: money('credit_limit').notNull().default('0'),
    openingBalance: money('opening_balance').notNull().default('0'),
    hiddenLedgerBalance: numeric('hidden_ledger_balance', {
      precision: 12,
      scale: 2,
    })
      .notNull()
      .default('0'),
    profileImageUrl: text('profile_image_url'),
    profileMediaAssetId: uuid('profile_media_asset_id'),
    connectedSince: date('connected_since'),
    notes: text('notes'),
    isActive: boolean('is_active').notNull().default(true),
  },
  (table) => [
    uniqueIndex('uq_parties_business_mobile_active')
      .on(table.businessId, table.mobile)
      .where(sql`${table.isDeleted} = false AND ${table.mobile} IS NOT NULL`),
    sql`CHECK (${table.creditLimit} >= 0)`,
    sql`CHECK (${table.hiddenLedgerBalance} >= 0)`,
    syncPullIndex(
      'parties',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const partyPhones = pgTable(
  'party_phones',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    partyId: uuid('party_id')
      .notNull()
      .references(() => parties.id),
    mobile: text('mobile').notNull(),
    label: text('label'),
    sortOrder: integer('sort_order').notNull().default(0),
  },
  (table) => [
    uniqueIndex('uq_party_phones_business_mobile_active')
      .on(table.businessId, table.mobile)
      .where(sql`${table.isDeleted} = false`),
  ],
);

export const partyLinks = pgTable(
  'party_links',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    partyId: uuid('party_id')
      .notNull()
      .references(() => parties.id),
    linkedPartyId: uuid('linked_party_id')
      .notNull()
      .references(() => parties.id),
    linkType: text('link_type').notNull(),
  },
  (table) => [
    uniqueIndex('uq_party_links_business_parties').on(
      table.businessId,
      table.partyId,
      table.linkedPartyId,
    ),
  ],
);

export const partyVisits = pgTable('party_visits', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  partyId: uuid('party_id')
    .notNull()
    .references(() => parties.id),
  visitDate: timestamptz('visit_date').notNull(),
  purpose: visitPurposeEnum('purpose').notNull(),
  saleType: text('sale_type'),
  notes: text('notes'),
  recordedBy: uuid('recorded_by').references(() => users.id),
});

export const partyAttachments = pgTable('party_attachments', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  partyId: uuid('party_id')
    .notNull()
    .references(() => parties.id),
  fileUrl: text('file_url').notNull(),
  fileType: text('file_type').notNull(),
  label: text('label'),
});

export const partyTags = pgTable('party_tags', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  name: text('name').notNull(),
  color: text('color'),
});

export const partyTagAssignments = pgTable(
  'party_tag_assignments',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    partyId: uuid('party_id')
      .notNull()
      .references(() => parties.id),
    partyTagId: uuid('party_tag_id')
      .notNull()
      .references(() => partyTags.id),
  },
  (table) => [
    uniqueIndex('uq_party_tag_assignments_party_tag').on(
      table.partyId,
      table.partyTagId,
    ),
  ],
);

export const partyLoyaltyBalances = pgTable(
  'party_loyalty_balances',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    partyId: uuid('party_id')
      .notNull()
      .references(() => parties.id),
    pointsEarned: money('points_earned').notNull().default('0'),
    pointsAvailable: money('points_available').notNull().default('0'),
  },
  (table) => [
    uniqueIndex('uq_party_loyalty_balances_party').on(
      table.businessId,
      table.partyId,
    ),
    sql`CHECK (${table.pointsEarned} >= 0)`,
    sql`CHECK (${table.pointsAvailable} >= 0)`,
  ],
);

/** Immutable earn/redeem audit ledger for loyalty points */
export const loyaltyTransactions = pgTable(
  'loyalty_transactions',
  {
    id: uuidPrimaryKey(),
    businessId: uuid('business_id')
      .notNull()
      .references(() => businesses.id),
    partyId: uuid('party_id')
      .notNull()
      .references(() => parties.id),
    transactionType: loyaltyTransactionTypeEnum('transaction_type').notNull(),
    points: money('points').notNull(),
    balanceAfter: money('balance_after').notNull(),
    referenceId: uuid('reference_id'),
    referenceType: text('reference_type'),
    spendAmount: money('spend_amount'),
    rupeesPerPoint: money('rupees_per_point'),
    description: text('description'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    createdBy: uuid('created_by'),
  },
  (table) => [
    sql`CHECK (${table.points} > 0)`,
    sql`CHECK (${table.balanceAfter} >= 0)`,
  ],
);

export const leads = pgTable(
  'leads',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    company: text('company'),
    phone: text('phone'),
    email: text('email'),
    leadSource: leadSourceEnum('lead_source'),
    status: leadStatusEnum('status').notNull().default('new'),
    assignedTo: text('assigned_to'),
    notes: text('notes'),
  },
  (table) => [
    syncPullIndex('leads', table.businessId, table.updatedAt, table.isDeleted),
  ],
);

export const leadActivities = pgTable(
  'lead_activities',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    leadId: uuid('lead_id')
      .notNull()
      .references(() => leads.id),
    type: leadActivityTypeEnum('type').notNull(),
    notes: text('notes'),
    addedBy: text('added_by'),
  },
  (table) => [
    syncPullIndex(
      'lead_activities',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const contacts = pgTable(
  'contacts',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    firstName: text('first_name'),
    lastName: text('last_name'),
    salutation: text('salutation'),
    accountName: text('account_name'),
    phone: text('phone'),
    email: text('email'),
    assignedTo: text('assigned_to'),
    title: text('title'),
    description: text('description'),
  },
  (table) => [
    syncPullIndex(
      'contacts',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

/** Seller-only shortfall ledger — never exposed on customer-facing documents */
export const hiddenLedgerEntries = pgTable(
  'hidden_ledger_entries',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    partyId: uuid('party_id')
      .notNull()
      .references(() => parties.id),
    saleId: uuid('sale_id').references(() => salesDocuments.id),
    invoiceId: uuid('invoice_id').references(() => salesDocuments.id),
    amount: money('amount').notNull(),
    recoveredAmount: money('recovered_amount').notNull().default('0'),
    remainingAmount: money('remaining_amount').notNull(),
    status: hiddenLedgerEntryStatusEnum('status').notNull().default('pending'),
  },
  (table) => [
    sql`CHECK (${table.amount} > 0)`,
    sql`CHECK (${table.recoveredAmount} >= 0)`,
    sql`CHECK (${table.remainingAmount} >= 0)`,
    sql`CHECK (${table.recoveredAmount} <= ${table.amount})`,
  ],
);

/** Immutable audit trail for hidden ledger recoveries (Phase 2+) */
export const hiddenLedgerRecoveryRecords = pgTable(
  'hidden_ledger_recovery_records',
  {
    id: uuidPrimaryKey(),
    businessId: businessId(),
    ledgerEntryId: uuid('ledger_entry_id')
      .notNull()
      .references(() => hiddenLedgerEntries.id),
    saleId: uuid('sale_id').references(() => salesDocuments.id),
    recoveredAmount: money('recovered_amount').notNull(),
    recoveredBy: uuid('recovered_by').references(() => users.id),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
    deletedAt: timestamptz('deleted_at'),
    isDeleted: boolean('is_deleted').notNull().default(false),
    syncVersion: integer('sync_version').notNull().default(1),
    deviceId: uuid('device_id'),
  },
  (table) => [sql`CHECK (${table.recoveredAmount} > 0)`],
);

export const contactActivities = pgTable(
  'contact_activities',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    contactId: uuid('contact_id')
      .notNull()
      .references(() => contacts.id),
    type: contactActivityTypeEnum('type').notNull(),
    notes: text('notes'),
    addedBy: text('added_by'),
  },
  (table) => [
    syncPullIndex(
      'contact_activities',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);

export const deals = pgTable(
  'deals',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    name: text('name').notNull(),
    stage: dealStageEnum('stage').notNull().default('qualification'),
    accountName: text('account_name'),
    assignedTo: text('assigned_to'),
    amount: money('amount').notNull().default('0'),
    expectedCloseDate: date('expected_close_date'),
    description: text('description'),
  },
  (table) => [
    syncPullIndex('deals', table.businessId, table.updatedAt, table.isDeleted),
  ],
);
