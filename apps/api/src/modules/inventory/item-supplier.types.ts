export type ItemSupplierRecord = {
  id: string;
  item_id: string;
  party_id: string;
  is_default: boolean;
  sort_order: number;
  party: {
    id: string;
    name: string;
    mobile: string | null;
    party_type: 'customer' | 'supplier' | 'both';
  };
};

export type ItemSupplierRow = {
  id: string;
  itemId: string;
  partyId: string;
  isDefault: boolean;
  sortOrder: number;
  partyName: string;
  partyMobile: string | null;
  partyType: 'customer' | 'supplier' | 'both';
};

export type ReplaceItemSupplierInput = {
  partyId: string;
  isDefault: boolean;
  sortOrder: number;
};

export type ReplaceItemSuppliersParams = {
  businessId: string;
  itemId: string;
  suppliers: ReplaceItemSupplierInput[];
  updatedBy?: string | null;
};
