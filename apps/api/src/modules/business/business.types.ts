export type BusinessListItem = {
  id: string;
  name: string;
  role: 'owner' | 'manager' | 'staff';
  gstin: string | null;
  phone: string | null;
  email: string | null;
  state_code: string;
  address: string | null;
  is_shared: boolean;
};

export type BusinessDetail = BusinessListItem;

export type CreateBusinessResponse = BusinessDetail;
