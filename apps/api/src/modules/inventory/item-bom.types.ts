export type ItemBomMaterialRecord = {
  id: string;
  item_id: string;
  raw_item_id: string;
  qty: string;
  unit_id: string;
  purchase_price: string;
  sort_order: number;
  raw_item: {
    id: string;
    name: string;
    base_unit: string;
    purchase_price: string;
  };
};

export type ItemBomCostRecord = {
  id: string;
  item_id: string;
  description: string;
  amount: string;
  sort_order: number;
};

export type ItemBomRecord = {
  materials: ItemBomMaterialRecord[];
  costs: ItemBomCostRecord[];
};

export type ReplaceItemBomMaterialInput = {
  rawItemId: string;
  qty: string;
  unitId: string;
  purchasePrice: string;
  sortOrder: number;
};

export type ReplaceItemBomCostInput = {
  id?: string;
  description: string;
  amount: string;
  sortOrder: number;
};

export type ReplaceItemBomParams = {
  businessId: string;
  itemId: string;
  materials: ReplaceItemBomMaterialInput[];
  costs: ReplaceItemBomCostInput[];
  updatedBy?: string | null;
};
