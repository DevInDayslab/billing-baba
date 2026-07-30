import { parseMoney } from './inventory.utils';
import type { StockLevelRecord, StockLevelRow } from './stock-level.types';

function resolveReorderLevel(row: StockLevelRow): string | null {
  return row.reorderLevel ?? row.itemReorderLevel;
}

function isLowStock(row: StockLevelRow): boolean {
  const threshold = resolveReorderLevel(row);
  if (!threshold) {
    return false;
  }
  return parseMoney(row.quantity) <= parseMoney(threshold);
}

export function toStockLevelRecord(row: StockLevelRow): StockLevelRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    item_name: row.itemName,
    godown_id: row.godownId,
    godown_name: row.godownName,
    quantity: row.quantity,
    average_cost: row.averageCost,
    reorder_level: resolveReorderLevel(row),
    is_low_stock: isLowStock(row),
    created_at: row.createdAt.toISOString(),
    updated_at: row.updatedAt.toISOString(),
  };
}
