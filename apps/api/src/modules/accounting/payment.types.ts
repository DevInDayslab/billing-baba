export type PaymentRecord = {
  id: string;
  party_id: string;
  direction: 'received' | 'paid';
  amount: string;
  discount_amount: string;
  payment_mode: string;
  bank_account_id: string | null;
  payment_date: string;
  reference_number: string | null;
  notes: string | null;
  short_payment_handling: string | null;
  created_at: string;
  updated_at: string;
  allocations?: PaymentAllocationRecord[];
};

export type PaymentAllocationRecord = {
  id: string;
  payment_id: string;
  sales_document_id: string | null;
  purchase_document_id: string | null;
  allocated_amount: string;
};

export type PaymentInsertValues = {
  businessId: string;
  partyId: string;
  direction: 'received' | 'paid';
  amount: string;
  discountAmount?: string;
  paymentMode: 'cash' | 'upi' | 'card' | 'cheque' | 'bank_transfer' | 'other';
  bankAccountId?: string | null;
  paymentDate?: Date;
  referenceNumber?: string | null;
  notes?: string | null;
  shortPaymentHandling?: string | null;
  source?: 'manual' | 'document_finalize' | 'razorpay_gateway';
  tdsSectionId?: string | null;
  tdsRate?: string | null;
  tdsAmount?: string | null;
  createdBy?: string | null;
  updatedBy?: string | null;
};

export type AllocationInsertValues = {
  businessId: string;
  paymentId: string;
  salesDocumentId?: string | null;
  purchaseDocumentId?: string | null;
  allocatedAmount: string;
  createdBy?: string | null;
  updatedBy?: string | null;
};
