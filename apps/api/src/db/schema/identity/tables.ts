import { sql } from 'drizzle-orm';
import {
  boolean,
  check,
  pgTable,
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

export const devices = pgTable('devices', {
  ...syncedBusinessColumns,
  businessId: businessId(),
  userId: uuid('user_id').references(() => users.id),
  deviceName: text('device_name').notNull(),
  platform: text('platform').notNull(),
  lastSyncAt: timestamptz('last_sync_at'),
});

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
