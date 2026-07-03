export type MovementType =
  | 'opening'
  | 'purchase'
  | 'sale'
  | 'sales_return'
  | 'purchase_return'
  | 'challan'
  | 'adjustment';

export type MovementRecord = {
  id: string;
  item_id: string;
  item_name: string;
  godown_id: string;
  godown_name: string;
  movement_type: MovementType;
  quantity_delta: string;
  cost_per_unit: string | null;
  reference_id: string | null;
  reference_type: string | null;
  created_by: string | null;
  created_at: string;
};

export type PaginatedMovementsResponse = {
  success: true;
  data: MovementRecord[];
  meta: { page: number; limit: number; total: number };
};

export type ListMovementsParams = {
  businessId: string;
  page: number;
  limit: number;
  itemId?: string;
  godownId?: string;
  movementType?: MovementType;
  sort: 'created_at';
  order: 'asc' | 'desc';
};

export type MovementRow = {
  id: string;
  itemId: string;
  itemName: string;
  godownId: string;
  godownName: string;
  movementType: MovementType;
  quantityDelta: string;
  costPerUnit: string | null;
  referenceId: string | null;
  referenceType: string | null;
  createdBy: string | null;
  createdAt: Date;
};

export type CreateMovementInput = {
  itemId: string;
  godownId: string;
  movementType: 'opening' | 'adjustment';
  quantityDelta: string;
  costPerUnit?: string | null;
  referenceId?: string | null;
  referenceType?: string | null;
  createdBy?: string | null;
};
