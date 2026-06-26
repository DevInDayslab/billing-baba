import { sql } from 'drizzle-orm';
import { boolean, pgTable, text, uniqueIndex } from 'drizzle-orm/pg-core';
import { syncedBusinessColumns, tenantRootColumns } from '../columns';
import { valuationMethodEnum } from '../enums';

export const businesses = pgTable(
  'businesses',
  {
    ...tenantRootColumns,
    name: text('name').notNull(),
    gstin: text('gstin'),
    stateCode: text('state_code').notNull(),
    address: text('address'),
    phone: text('phone'),
    email: text('email'),
    valuationMethod: valuationMethodEnum('valuation_method')
      .notNull()
      .default('average'),
  },
  (table) => [
    uniqueIndex('uq_businesses_gstin')
      .on(table.gstin)
      .where(sql`${table.gstin} IS NOT NULL`),
  ],
);

export const branches = pgTable('branches', {
  ...syncedBusinessColumns,
  businessId: syncedBusinessColumns.businessId
    .notNull()
    .references(() => businesses.id),
  name: text('name').notNull(),
  address: text('address'),
  isDefault: boolean('is_default').notNull().default(false),
});
