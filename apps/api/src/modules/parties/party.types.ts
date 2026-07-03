export type PartyRecord = {
  id: string;
  name: string;
  mobile: string | null;
  email: string | null;
  party_type: 'customer' | 'supplier' | 'both';
  party_category:
    | 'customer'
    | 'retailer'
    | 'wholesaler'
    | 'manufacturer'
    | 'custom'
    | null;
  pricing_tier: 'tier_1' | 'tier_2' | 'tier_3';
  gstin: string | null;
  state_code: string | null;
  state: string | null;
  area_id: string | null;
  credit_limit: string;
  opening_balance: string;
  balance: string;
  is_active: boolean;
  notes: string | null;
  created_at: string;
  updated_at: string;
};

export type PaginatedPartiesResponse = {
  success: true;
  data: PartyRecord[];
  meta: {
    page: number;
    limit: number;
    total: number;
  };
};

export type PartyInsertValues = {
  businessId: string;
  name: string;
  mobile: string | null;
  email: string | null;
  partyType: 'customer' | 'supplier' | 'both';
  partyCategory?:
    | 'customer'
    | 'retailer'
    | 'wholesaler'
    | 'manufacturer'
    | 'custom'
    | null;
  pricingTier: 'tier_1' | 'tier_2' | 'tier_3';
  gstin: string | null;
  stateCode: string | null;
  areaId?: string | null;
  creditLimit: string;
  openingBalance: string;
  notes: string | null;
  isActive: boolean;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type PartyUpdateValues = Partial<
  Omit<PartyInsertValues, 'businessId' | 'createdBy'>
> & {
  updatedBy?: string | null;
};

export type ListPartiesParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  partyType?: 'customer' | 'supplier' | 'both';
  isActive?: boolean;
  sort: 'name' | 'created_at' | 'opening_balance';
  order: 'asc' | 'desc';
};
