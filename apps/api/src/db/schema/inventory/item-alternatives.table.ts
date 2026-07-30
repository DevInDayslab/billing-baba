import { sql } from 'drizzle-orm';
import { index, integer, pgTable, uniqueIndex, uuid } from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { syncedBusinessColumns } from '../columns';
import { items } from './tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const itemAlternatives = pgTable(
  'item_alternatives',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    itemId: uuid('item_id')
      .notNull()
      .references(() => items.id),
    alternativeItemId: uuid('alternative_item_id')
      .notNull()
      .references(() => items.id),
    sortOrder: integer('sort_order').notNull().default(0),
  },
  (table) => [
    uniqueIndex('uq_item_alternatives_active')
      .on(table.businessId, table.itemId, table.alternativeItemId)
      .where(sql`${table.isDeleted} = false`),
    index('idx_item_alternatives_item')
      .on(table.businessId, table.itemId)
      .where(sql`${table.isDeleted} = false`),
  ],
);
