import { sql } from 'drizzle-orm';
import {
  boolean,
  check,
  integer,
  pgTable,
  primaryKey,
  text,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { syncedBusinessColumns, timestamptz, uuidPrimaryKey } from '../columns';
import { attendanceStatusEnum, userRoleEnum } from '../enums';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

/** Server-only global identity for OTP login (not synced to clients). */
export const accounts = pgTable(
  'accounts',
  {
    id: uuidPrimaryKey(),
    phone: text('phone').notNull(),
    name: text('name'),
    email: text('email'),
    avatarUrl: text('avatar_url'),
    avatarMediaAssetId: uuid('avatar_media_asset_id'),
    timezone: text('timezone').notNull().default('Asia/Kolkata'),
    language: text('language').notNull().default('en'),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  },
  (table) => [uniqueIndex('uq_accounts_phone').on(table.phone)],
);

export const users = pgTable(
  'users',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    accountId: uuid('account_id')
      .notNull()
      .references(() => accounts.id),
    name: text('name').notNull(),
    email: text('email'),
    phone: text('phone'),
    passwordHash: text('password_hash'),
    role: userRoleEnum('role').notNull().default('staff'),
    isActive: boolean('is_active').notNull().default(true),
  },
  (table) => [
    uniqueIndex('uq_users_business_email_active')
      .on(table.businessId, table.email)
      .where(sql`${table.isDeleted} = false AND ${table.email} IS NOT NULL`),
    uniqueIndex('uq_users_business_phone_active')
      .on(table.businessId, table.phone)
      .where(sql`${table.isDeleted} = false AND ${table.phone} IS NOT NULL`),
    check(
      'users_email_or_phone',
      sql`${table.email} IS NOT NULL OR ${table.phone} IS NOT NULL`,
    ),
  ],
);

/** Client device UUID is stored in `id`; PK is (business_id, id) for multi-business sync. */
export const devices = pgTable(
  'devices',
  {
    id: uuid('id').notNull(),
    businessId: businessId(),
    createdAt: timestamptz('created_at').notNull().defaultNow(),
    updatedAt: timestamptz('updated_at').notNull().defaultNow(),
    deletedAt: timestamptz('deleted_at'),
    isDeleted: boolean('is_deleted').notNull().default(false),
    createdBy: uuid('created_by'),
    updatedBy: uuid('updated_by'),
    syncVersion: integer('sync_version').notNull().default(1),
    deviceId: uuid('device_id'),
    userId: uuid('user_id').references(() => users.id),
    deviceName: text('device_name').notNull(),
    platform: text('platform').notNull(),
    appVersion: text('app_version').notNull().default('0.0.0'),
    lastSyncAt: timestamptz('last_sync_at'),
  },
  (table) => [
    primaryKey({ columns: [table.businessId, table.id], name: 'devices_pkey' }),
  ],
);

export const refreshTokens = pgTable('refresh_tokens', {
  id: uuid('id').primaryKey().defaultRandom(),
  accountId: uuid('account_id')
    .notNull()
    .references(() => accounts.id),
  userId: uuid('user_id').references(() => users.id),
  tokenHash: text('token_hash').notNull(),
  expiresAt: timestamptz('expires_at').notNull(),
  revokedAt: timestamptz('revoked_at'),
  createdAt: timestamptz('created_at').notNull().defaultNow(),
});

/** Server-only device trust for "Remember for 30 days" (survives logout). */
export const deviceTrustTokens = pgTable('device_trust_tokens', {
  id: uuid('id').primaryKey().defaultRandom(),
  accountId: uuid('account_id')
    .notNull()
    .references(() => accounts.id),
  phone: text('phone').notNull(),
  deviceId: uuid('device_id').notNull(),
  tokenHash: text('token_hash').notNull(),
  expiresAt: timestamptz('expires_at').notNull(),
  revokedAt: timestamptz('revoked_at'),
  createdAt: timestamptz('created_at').notNull().defaultNow(),
});

export const attendanceRecords = pgTable('attendance_records', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  userId: uuid('user_id')
    .notNull()
    .references(() => users.id),
  clockInAt: timestamptz('clock_in_at').notNull(),
  clockOutAt: timestamptz('clock_out_at'),
  status: attendanceStatusEnum('status').notNull().default('present'),
  notes: text('notes'),
});
