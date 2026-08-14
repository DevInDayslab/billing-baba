import { sql } from 'drizzle-orm';
import {
  boolean,
  index,
  integer,
  pgTable,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { parties } from '../crm/tables';
import { syncedBusinessColumns } from '../columns';
import { syncPullIndex } from '../sync-pull-index';
import { items } from './tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const itemSuppliers = pgTable(
  'item_suppliers',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    itemId: uuid('item_id')
      .notNull()
      .references(() => items.id),
    partyId: uuid('party_id')
      .notNull()
      .references(() => parties.id),
    isDefault: boolean('is_default').notNull().default(false),
    sortOrder: integer('sort_order').notNull().default(0),
  },
  (table) => [
    uniqueIndex('uq_item_suppliers_active')
      .on(table.businessId, table.itemId, table.partyId)
      .where(sql`${table.isDeleted} = false`),
    index('idx_item_suppliers_item')
      .on(table.businessId, table.itemId)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'item_suppliers',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);
