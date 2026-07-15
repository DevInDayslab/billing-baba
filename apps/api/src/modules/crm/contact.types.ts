export type ContactRecord = {
  id: string;
  business_id: string;
  name: string;
  first_name: string | null;
  last_name: string | null;
  salutation: string | null;
  account_name: string | null;
  phone: string | null;
  email: string | null;
  assigned_to: string | null;
  title: string | null;
  description: string | null;
  created_at: string;
  updated_at: string;
};

export type ContactActivityRecord = {
  id: string;
  contact_id: string;
  business_id: string;
  type: 'call' | 'email' | 'meeting' | 'note' | 'status_change';
  notes: string | null;
  added_by: string | null;
  created_at: string;
  updated_at: string;
};

export type ContactWithActivitiesRecord = ContactRecord & {
  activities: ContactActivityRecord[];
};

export type ListContactsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  accountName?: string;
  assignedTo?: string;
  from?: Date;
  to?: Date;
};

export type ContactInsertValues = {
  id?: string;
  businessId: string;
  name: string;
  firstName?: string | null;
  lastName?: string | null;
  salutation?: string | null;
  accountName?: string | null;
  phone?: string | null;
  email?: string | null;
  assignedTo?: string | null;
  title?: string | null;
  description?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type ContactUpdateValues = Partial<
  Omit<ContactInsertValues, 'businessId' | 'createdBy'>
> & {
  updatedBy?: string | null;
  isDeleted?: boolean;
  deletedAt?: Date | null;
};

export type ContactActivityInsertValues = {
  businessId: string;
  contactId: string;
  type: ContactActivityRecord['type'];
  notes?: string | null;
  addedBy?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};
