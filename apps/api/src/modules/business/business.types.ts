export type BusinessListItem = {
  id: string;
  name: string;
  role: 'owner' | 'manager' | 'staff';
  gstin: string | null;
  phone: string | null;
  email: string | null;
  state_code: string;
  address: string | null;
  owner_name: string | null;
  is_shared: boolean;
};

export type BusinessDetail = BusinessListItem;

export type CreateBusinessResponse = BusinessDetail;

export type BusinessProfile = {
  id: string;
  name: string;
  owner_name: string | null;
  phone: string | null;
  email: string | null;
  gstin: string | null;
  business_type: string | null;
  business_category: string | null;
  state: string | null;
  pincode: string | null;
  currency: string;
  address: string | null;
  timezone: string;
  language: string;
  logo_url: string | null;
  signature_url: string | null;
  stamp_url: string | null;
  upi_qr_url: string | null;
};
