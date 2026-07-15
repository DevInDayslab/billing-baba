export type LeadRecord = {
  id: string;
  business_id: string;
  name: string;
  company: string | null;
  phone: string | null;
  email: string | null;
  lead_source:
    | 'google_ads'
    | 'referral'
    | 'website'
    | 'walk_in'
    | 'other'
    | null;
  status: 'new' | 'contacted' | 'qualified' | 'converted' | 'lost';
  assigned_to: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
};

export type LeadActivityRecord = {
  id: string;
  lead_id: string;
  business_id: string;
  type: 'call' | 'email' | 'meeting' | 'note' | 'status_change';
  notes: string | null;
  added_by: string | null;
  created_at: string;
  updated_at: string;
};

export type LeadWithActivitiesRecord = LeadRecord & {
  activities: LeadActivityRecord[];
};

export type ListLeadsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  status?: LeadRecord['status'];
  leadSource?: NonNullable<LeadRecord['lead_source']>;
  from?: Date;
  to?: Date;
};

export type LeadInsertValues = {
  id?: string;
  businessId: string;
  name: string;
  company?: string | null;
  phone?: string | null;
  email?: string | null;
  leadSource?: LeadRecord['lead_source'];
  status?: LeadRecord['status'];
  assignedTo?: string | null;
  notes?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type LeadUpdateValues = Partial<
  Omit<LeadInsertValues, 'businessId' | 'createdBy'>
> & {
  updatedBy?: string | null;
  isDeleted?: boolean;
  deletedAt?: Date | null;
};

export type LeadActivityInsertValues = {
  businessId: string;
  leadId: string;
  type: LeadActivityRecord['type'];
  notes?: string | null;
  addedBy?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};
