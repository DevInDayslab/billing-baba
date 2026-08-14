import { sql } from 'drizzle-orm';
import { index, integer, pgTable, uniqueIndex, uuid } from 'drizzle-orm/pg-core';
import { businesses } from '../business/tables';
import { syncedBusinessColumns, money } from '../columns';
import { syncPullIndex } from '../sync-pull-index';
import { unitDefinitions } from './tables';
import { items } from './tables';

const businessId = () =>
  syncedBusinessColumns.businessId.notNull().references(() => businesses.id);

export const itemBomMaterials = pgTable(
  'item_bom_materials',
  {
    ...syncedBusinessColumns,
    businessId: businessId(),
    itemId: uuid('item_id')
      .notNull()
      .references(() => items.id),
    rawItemId: uuid('raw_item_id')
      .notNull()
      .references(() => items.id),
    qty: money('qty').notNull(),
    unitId: uuid('unit_id')
      .notNull()
      .references(() => unitDefinitions.id),
    purchasePrice: money('purchase_price').notNull().default('0'),
    sortOrder: integer('sort_order').notNull().default(0),
  },
  (table) => [
    uniqueIndex('uq_item_bom_materials_active')
      .on(table.businessId, table.itemId, table.rawItemId)
      .where(sql`${table.isDeleted} = false`),
    index('idx_item_bom_materials_item')
      .on(table.businessId, table.itemId)
      .where(sql`${table.isDeleted} = false`),
    syncPullIndex(
      'item_bom_materials',
      table.businessId,
      table.updatedAt,
      table.isDeleted,
    ),
  ],
);
