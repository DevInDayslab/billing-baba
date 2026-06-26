import { boolean, integer, pgTable, text, uniqueIndex } from 'drizzle-orm/pg-core';
import { money, syncedBusinessColumns } from '../columns';
import {
  creditLimitActionEnum,
  taxTypeEnum,
  valuationMethodEnum,
} from '../enums';
import { businesses } from '../business/tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const areas = pgTable('areas', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  name: text('name').notNull(),
});

export const businessSettings = pgTable('business_settings', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  valuationMethod: valuationMethodEnum('valuation_method').notNull().default('average'),
  defaultTaxType: taxTypeEnum('default_tax_type').notNull().default('none'),
  invoiceTerms: text('invoice_terms'),
  enablePriceConflictAlerts: boolean('enable_price_conflict_alerts').notNull().default(true),
  creditLimitAction: creditLimitActionEnum('credit_limit_action').notNull().default('warn'),
});

export const taxRates = pgTable('tax_rates', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  name: text('name').notNull(),
  rate: money('rate').notNull(),
  isDefault: boolean('is_default').notNull().default(false),
});

export const documentNumberSequences = pgTable(
  'document_number_sequences',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    documentSeries: text('document_series').notNull(),
    prefix: text('prefix'),
    nextNumber: integer('next_number').notNull().default(1),
    fiscalYear: text('fiscal_year').notNull(),
  },
  (table) => [
    uniqueIndex('uq_document_number_sequences_business_series_year').on(
      table.businessId,
      table.documentSeries,
      table.fiscalYear,
    ),
  ],
);

export const loyaltyRules = pgTable('loyalty_rules', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  rupeesPerPoint: money('rupees_per_point').notNull(),
  isActive: boolean('is_active').notNull().default(true),
});
