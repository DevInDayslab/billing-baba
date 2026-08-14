import type {
  ItemBomCostRecord,
  ItemBomMaterialRecord,
} from './item-bom.types';

type MaterialRow = {
  id: string;
  itemId: string;
  rawItemId: string;
  qty: string;
  unitId: string;
  purchasePrice: string;
  sortOrder: number;
  rawItemName: string;
  rawItemBaseUnit: string;
  rawItemPurchasePrice: string;
};

type CostRow = {
  id: string;
  itemId: string;
  description: string;
  amount: string;
  sortOrder: number;
};

export function toItemBomMaterialRecord(row: MaterialRow): ItemBomMaterialRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    raw_item_id: row.rawItemId,
    qty: row.qty,
    unit_id: row.unitId,
    purchase_price: row.purchasePrice,
    sort_order: row.sortOrder,
    raw_item: {
      id: row.rawItemId,
      name: row.rawItemName,
      base_unit: row.rawItemBaseUnit,
      purchase_price: row.rawItemPurchasePrice,
    },
  };
}

export function toItemBomCostRecord(row: CostRow): ItemBomCostRecord {
  return {
    id: row.id,
    item_id: row.itemId,
    description: row.description,
    amount: row.amount,
    sort_order: row.sortOrder,
  };
}
