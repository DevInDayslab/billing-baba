import type { PricingTier } from '../../shared/pricing/pricing-tier';

export type PartyRecord = {
  id: string;
  name: string;
  legal_name: string | null;
  alias: string | null;
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
  party_group: string | null;
  area_code: string | null;
  pricing_tier: PricingTier;
  default_price_tier: PricingTier;
  gstin: string | null;
  state_code: string | null;
  state: string | null;
  area_id: string | null;
  credit_limit: string;
  opening_balance: string;
  balance: string;
  is_active: boolean;
  notes: string | null;
  profile_image_url: string | null;
  profile_media_asset_id: string | null;
  additional_phones: string[];
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
  legalName?: string | null;
  alias?: string | null;
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
  partyGroup?: string | null;
  areaCode?: string | null;
  pricingTier: PricingTier;
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

export type PartyDeleteReferences = {
  sales: number;
  purchases: number;
  payments: number;
  salesReturns: number;
  purchaseReturns: number;
};

export type PartyDeleteStatus =
  | { canDelete: true }
  | { canDelete: false; references: PartyDeleteReferences };

export type PartyDeleteAction = 'deleted' | 'deactivated';
