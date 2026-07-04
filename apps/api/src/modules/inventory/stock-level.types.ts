export type StockLevelRecord = {
  id: string;
  item_id: string;
  item_name: string;
  godown_id: string;
  godown_name: string;
  quantity: string;
  average_cost: string;
  reorder_level: string | null;
  is_low_stock: boolean;
  created_at: string;
  updated_at: string;
};

export type PaginatedStockLevelsResponse = {
  success: true;
  data: StockLevelRecord[];
  meta: { page: number; limit: number; total: number };
};

export type ListStockLevelsParams = {
  businessId: string;
  page: number;
  limit: number;
  itemId?: string;
  godownId?: string;
  lowStock?: boolean;
  q?: string;
  sort: 'quantity' | 'created_at';
  order: 'asc' | 'desc';
};

export type StockLevelRow = {
  id: string;
  itemId: string;
  itemName: string;
  godownId: string;
  godownName: string;
  quantity: string;
  averageCost: string;
  reorderLevel: string | null;
  itemReorderLevel: string | null;
  createdAt: Date;
  updatedAt: Date;
};
