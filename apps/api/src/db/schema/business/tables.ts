import { sql } from 'drizzle-orm';
import { boolean, pgTable, text, uniqueIndex, uuid } from 'drizzle-orm/pg-core';
import {
  syncedBusinessColumns,
  tenantRootColumns,
  timestamptz,
} from '../columns';
import {
  subscriptionPlanEnum,
  subscriptionStatusEnum,
  valuationMethodEnum,
} from '../enums';

export const businesses = pgTable(
  'businesses',
  {
    ...tenantRootColumns,
    name: text('name').notNull(),
    gstin: text('gstin'),
    pan: text('pan'),
    tan: text('tan'),
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
    /** UPI VPA for dynamic Scan-to-Pay (e.g. merchant@upi) */
    upiId: text('upi_id'),
    valuationMethod: valuationMethodEnum('valuation_method')
      .notNull()
      .default('average'),
    currentPlan: subscriptionPlanEnum('current_plan')
      .notNull()
      .default('no_plan'),
    planStatus: subscriptionStatusEnum('plan_status')
      .notNull()
      .default('active'),
    planExpiresAt: timestamptz('plan_expires_at'),
    deletionRequestedAt: timestamptz('deletion_requested_at'),
    scheduledDeletionAt: timestamptz('scheduled_deletion_at'),
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
