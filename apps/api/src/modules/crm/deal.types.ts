export type DealRecord = {
  id: string;
  business_id: string;
  name: string;
  stage:
    | 'qualification'
    | 'needs_analysis'
    | 'value_proposition'
    | 'identify_decision_makers'
    | 'proposal_price_quote'
    | 'negotiation_review'
    | 'closed_won'
    | 'closed_lost'
    | 'closed_lost_to_competition';
  account_name: string | null;
  assigned_to: string | null;
  amount: string;
  expected_close_date: string | null;
  description: string | null;
  created_at: string;
  updated_at: string;
};

export type ListDealsParams = {
  businessId: string;
  page: number;
  limit: number;
  q?: string;
  accountName?: string;
  assignedTo?: string;
  stage?: DealRecord['stage'];
  from?: Date;
  to?: Date;
};

export type DealInsertValues = {
  id?: string;
  businessId: string;
  name: string;
  stage?: DealRecord['stage'];
  accountName?: string | null;
  assignedTo?: string | null;
  amount?: string;
  expectedCloseDate?: string | null;
  description?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type DealUpdateValues = Partial<
  Omit<DealInsertValues, 'businessId' | 'createdBy'>
> & {
  updatedBy?: string | null;
  isDeleted?: boolean;
  deletedAt?: Date | null;
};
