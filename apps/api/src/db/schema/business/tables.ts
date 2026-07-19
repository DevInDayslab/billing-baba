import { sql } from 'drizzle-orm';
import { boolean, pgTable, text, uniqueIndex, uuid } from 'drizzle-orm/pg-core';
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
    businessType: text('business_type'),
    businessCategory: text('business_category'),
    pincode: text('pincode'),
    currency: text('currency').notNull().default('INR'),
    timezone: text('timezone').notNull().default('Asia/Kolkata'),
    language: text('language').notNull().default('en'),
    logoUrl: text('logo_url'),
    signatureUrl: text('signature_url'),
    logoMediaAssetId: uuid('logo_media_asset_id'),
    signatureMediaAssetId: uuid('signature_media_asset_id'),
    stampMediaAssetId: uuid('stamp_media_asset_id'),
    upiQrMediaAssetId: uuid('upi_qr_media_asset_id'),
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
