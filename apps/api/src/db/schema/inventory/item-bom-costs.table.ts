import { sql } from 'drizzle-orm';
import { index, integer, pgTable, text, uuid } from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { syncedBusinessColumns, money } from '../columns';
import { syncPullIndex } from '../sync-pull-index';
import { items } from './tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const itemBomCosts = pgTable(
  'item_bom_costs',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    itemId: uuid('item_id')
      .notNull()
      .references(() => items.id),
    description: text('description').notNull(),
    amount: money('amount').notNull().default('0'),
    sortOrder: integer('sort_order').notNull().default(0),
  },
  (table) => [
    index('idx_item_bom_costs_item')
      .on(table.businessId, table.itemId)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'item_bom_costs',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);
