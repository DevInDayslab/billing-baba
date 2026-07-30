import { and, eq, inArray, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { stockLevels } from '../../db/schema/inventory/tables';
import {
  salesDocumentLines,
  salesDocuments,
} from '../../db/schema/sales/tables';
import { normalizeMoney, parseMoney } from './inventory.utils';
import type { ItemDetailRecord, ItemListRecord } from './item.types';

const SALE_ORDER_FULFILLMENT_TYPES = [
  'delivery_challan',
  'tax_invoice',
  'bill_of_supply',
  'normal_invoice',
  'pos',
] as const;

export type ItemStockSummary = {
  quantity: string;
  reserved_quantity: string;
  available_for_sale: string;
};

export async function loadStockQuantitiesByItem(
  db: Database,
  businessId: string,
  itemIds?: string[],
): Promise<Map<string, number>> {
  const filters = [
    eq(stockLevels.businessId, businessId),
    eq(stockLevels.isDeleted, false),
  ];

  if (itemIds && itemIds.length > 0) {
    filters.push(inArray(stockLevels.itemId, itemIds));
  }

  const rows = await db
    .select({
      itemId: stockLevels.itemId,
      total: sql<string>`COALESCE(SUM(${stockLevels.quantity}::numeric), 0)`,
    })
    .from(stockLevels)
    .where(and(...filters))
    .groupBy(stockLevels.itemId);

  return new Map(rows.map((row) => [row.itemId, parseMoney(row.total)]));
}

async function loadFulfilledQuantitiesFromDescendants(
  db: Database,
  businessId: string,
  rootDocumentId: string,
): Promise<Map<string, number>> {
  const fulfilled = new Map<string, number>();
  const queue = [rootDocumentId];
  const visited = new Set<string>();

  while (queue.length > 0) {
    const parentId = queue.shift()!;
    if (visited.has(parentId)) {
      continue;
    }
    visited.add(parentId);

    const children = await db
      .select({
        id: salesDocuments.id,
        documentType: salesDocuments.documentType,
      })
      .from(salesDocuments)
      .where(
        and(
          eq(salesDocuments.businessId, businessId),
          eq(salesDocuments.convertedFromId, parentId),
          eq(salesDocuments.status, 'finalized'),
          eq(salesDocuments.isDeleted, false),
        ),
      );

    for (const child of children) {
      if (
        SALE_ORDER_FULFILLMENT_TYPES.includes(
          child.documentType as (typeof SALE_ORDER_FULFILLMENT_TYPES)[number],
        )
      ) {
        const lines = await db
          .select({
            itemId: salesDocumentLines.itemId,
            quantity: salesDocumentLines.quantity,
          })
          .from(salesDocumentLines)
          .where(
            and(
              eq(salesDocumentLines.businessId, businessId),
              eq(salesDocumentLines.salesDocumentId, child.id),
              eq(salesDocumentLines.isDeleted, false),
            ),
          );

        for (const line of lines) {
          const qty = parseMoney(line.quantity);
          fulfilled.set(line.itemId, (fulfilled.get(line.itemId) ?? 0) + qty);
        }
      }

      queue.push(child.id);
    }
  }

  return fulfilled;
}

export async function loadReservedQuantitiesByItem(
  db: Database,
  businessId: string,
  itemIds?: string[],
): Promise<Map<string, number>> {
  const orders = await db
    .select({ id: salesDocuments.id })
    .from(salesDocuments)
    .where(
      and(
        eq(salesDocuments.businessId, businessId),
        eq(salesDocuments.documentType, 'sale_order'),
        eq(salesDocuments.status, 'finalized'),
        eq(salesDocuments.isDeleted, false),
      ),
    );

  const reserved = new Map<string, number>();

  for (const order of orders) {
    const lineFilters = [
      eq(salesDocumentLines.businessId, businessId),
      eq(salesDocumentLines.salesDocumentId, order.id),
      eq(salesDocumentLines.isDeleted, false),
    ];
    if (itemIds && itemIds.length > 0) {
      lineFilters.push(inArray(salesDocumentLines.itemId, itemIds));
    }

    const orderLines = await db
      .select({
        itemId: salesDocumentLines.itemId,
        quantity: salesDocumentLines.quantity,
      })
      .from(salesDocumentLines)
      .where(and(...lineFilters));

    if (orderLines.length === 0) {
      continue;
    }

    const fulfilled = await loadFulfilledQuantitiesFromDescendants(
      db,
      businessId,
      order.id,
    );

    for (const line of orderLines) {
      const orderQty = parseMoney(line.quantity);
      const fulfilledQty = fulfilled.get(line.itemId) ?? 0;
      const remaining = Math.max(0, orderQty - fulfilledQty);
      if (remaining > 0) {
        reserved.set(line.itemId, (reserved.get(line.itemId) ?? 0) + remaining);
      }
    }
  }

  return reserved;
}

export function buildItemStockSummary(
  itemId: string,
  physicalByItem: Map<string, number>,
  reservedByItem: Map<string, number>,
): ItemStockSummary {
  const physical = physicalByItem.get(itemId) ?? 0;
  const reserved = reservedByItem.get(itemId) ?? 0;
  const available = Math.max(0, physical - reserved);

  return {
    quantity: physical.toFixed(4),
    reserved_quantity: reserved.toFixed(4),
    available_for_sale: available.toFixed(4),
  };
}

export function enrichItemListRecord(
  item: ItemListRecord,
  physicalByItem: Map<string, number>,
  reservedByItem: Map<string, number>,
): ItemListRecord {
  if (!item.has_stock_tracking) {
    return item;
  }

  const summary = buildItemStockSummary(
    item.id,
    physicalByItem,
    reservedByItem,
  );
  return {
    ...item,
    ...summary,
  };
}

export function enrichItemDetailRecord(
  item: ItemDetailRecord,
  physicalByItem: Map<string, number>,
  reservedByItem: Map<string, number>,
): ItemDetailRecord {
  if (!item.has_stock_tracking) {
    return item;
  }

  const summary = buildItemStockSummary(
    item.id,
    physicalByItem,
    reservedByItem,
  );
  return {
    ...item,
    ...summary,
  };
}

export async function loadStockSummariesForItems(
  db: Database,
  businessId: string,
  itemIds: string[],
): Promise<{
  physicalByItem: Map<string, number>;
  reservedByItem: Map<string, number>;
}> {
  const scopedIds = itemIds.length > 0 ? itemIds : undefined;
  const [physicalByItem, reservedByItem] = await Promise.all([
    loadStockQuantitiesByItem(db, businessId, scopedIds),
    loadReservedQuantitiesByItem(db, businessId, scopedIds),
  ]);

  return { physicalByItem, reservedByItem };
}
