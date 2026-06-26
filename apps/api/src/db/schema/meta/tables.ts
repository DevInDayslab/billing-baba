import { integer, pgTable, timestamp } from 'drizzle-orm/pg-core';

/** Tracks applied Drizzle migration version for sync handshake */
export const schemaVersion = pgTable('schema_version', {
  id: integer('id').primaryKey().default(1),
  version: integer('version').notNull().default(1),
  updatedAt: timestamp('updated_at', { withTimezone: true, mode: 'date' })
    .notNull()
    .defaultNow(),
});
