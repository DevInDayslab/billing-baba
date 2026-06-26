import {
  boolean,
  integer,
  numeric,
  timestamp,
  uuid,
} from 'drizzle-orm/pg-core';

/** NUMERIC(18,4) for money and quantities per 04-database.md */
export const money = (name: string) =>
  numeric(name, { precision: 18, scale: 4 });

export const uuidPrimaryKey = () => uuid('id').primaryKey().defaultRandom();

export const timestamptz = (name: string) =>
  timestamp(name, { withTimezone: true, mode: 'date' });

/** Standard columns on every synced business table (04-database.md) */
export const syncedBusinessColumns = {
  id: uuidPrimaryKey(),
  businessId: uuid('business_id').notNull(),
  createdAt: timestamptz('created_at').notNull().defaultNow(),
  updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  deletedAt: timestamptz('deleted_at'),
  isDeleted: boolean('is_deleted').notNull().default(false),
  createdBy: uuid('created_by'),
  updatedBy: uuid('updated_by'),
  syncVersion: integer('sync_version').notNull().default(1),
  deviceId: uuid('device_id'),
};

/** Tenant root — no business_id self-reference */
export const tenantRootColumns = {
  id: uuidPrimaryKey(),
  createdAt: timestamptz('created_at').notNull().defaultNow(),
  updatedAt: timestamptz('updated_at').notNull().defaultNow(),
  deletedAt: timestamptz('deleted_at'),
  isDeleted: boolean('is_deleted').notNull().default(false),
  syncVersion: integer('sync_version').notNull().default(1),
};
