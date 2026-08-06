import type { PaymentRecord } from '../accounting/payment.types';

export type GatewayPaymentIntentType =
  | 'payment_in'
  | 'payment_out'
  | 'sale_invoice'
  | 'purchase_bill'
  | 'pos'
  | 'party_outstanding'
  | 'advance';

export type GatewayPaymentIntentStatus =
  | 'created'
  | 'checkout_open'
  | 'callback_received'
  | 'verifying'
  | 'verified'
  | 'failed'
  | 'cancelled'
  | 'expired';

export type CreateGatewayOrderInput = {
  businessId: string;
  accountId: string;
  userId?: string;
  idempotencyKey?: string;
  intentType: GatewayPaymentIntentType;
  partyId: string;
  amount: string;
  discountAmount?: string;
  notes?: string | null;
  shortPaymentHandling?: 'official_balance' | 'unrecovered';
  shortfallAmount?: string;
  allocations?: Array<{
    sales_document_id?: string;
    purchase_document_id?: string;
    allocated_amount: string;
  }>;
  referenceNumber?: string | null;
  invoiceNumber?: string | null;
};

export type VerifyGatewayPaymentInput = {
  businessId: string;
  accountId: string;
  userId?: string;
  intentId: string;
  razorpayOrderId: string;
  razorpayPaymentId: string;
  razorpaySignature: string;
};

export type CreateGatewayOrderResponse = {
  id: string;
  order_id: string;
  amount: number;
  currency: string;
  receipt: string;
  razorpay_key: string;
  customer: {
    name: string;
    email: string;
    contact: string;
  };
  merchant: {
    name: string;
  };
  theme: {
    color: string;
  };
  checkout: {
    timeout: number;
    retry: { enabled: boolean; max_count: number };
    remember_customer: boolean;
    send_sms_hash: boolean;
    readonly: { email: boolean; contact: boolean };
    notes: Record<string, string>;
  };
};

export type VerifyGatewayPaymentResponse = {
  status: 'verified' | 'failed' | 'pending';
  payment?: PaymentRecord;
  failure_reason?: string;
};

export type GatewayPaymentStatusResponse = {
  id: string;
  status: GatewayPaymentIntentStatus;
  order_id: string;
  amount: number;
  currency: string;
  business_name: string;
  customer_name: string;
  payment?: PaymentRecord;
  failure_reason?: string | null;
};
