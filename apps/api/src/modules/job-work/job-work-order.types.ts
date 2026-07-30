export type JobWorkOrderRecord = {
  id: string;
  party_id: string | null;
  job_number: string | null;
  status: 'open' | 'closed' | 'cancelled';
  order_date: string;
  delivery_date: string | null;
  finished_good_name: string;
  finished_good_quantity: string;
  finished_good_unit: string;
  raw_materials_total: string;
  additional_costs_total: string;
  grand_total: string;
  notes: string | null;
  created_at: string;
  updated_at: string;
  raw_materials?: Array<{
    id: string;
    item_id: string;
    quantity: string;
    unit: string;
    purchase_price: string;
    line_total: string;
    sort_order: number;
  }>;
  additional_costs?: Array<{
    id: string;
    label: string;
    amount: string;
    sort_order: number;
  }>;
};

export type JobWorkOrderInsertValues = {
  businessId: string;
  partyId?: string | null;
  jobNumber?: string | null;
  orderDate?: Date;
  deliveryDate?: Date | null;
  finishedGoodName: string;
  finishedGoodQuantity?: string;
  finishedGoodUnit?: string;
  rawMaterialsTotal?: string;
  additionalCostsTotal?: string;
  grandTotal?: string;
  notes?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};
