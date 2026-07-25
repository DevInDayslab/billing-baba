import type { PurchasablePlan } from './subscription.constants';

export type SubscriptionPlanCode = 'no_plan' | 'gold' | 'platinum';

export type SubscriptionStatusCode =
  | 'active'
  | 'expired'
  | 'pending'
  | 'cancelled';

export type PlanCatalogItem = {
  plan: SubscriptionPlanCode;
  name: string;
  price: string;
  durationDays: number;
  isActive: boolean;
};

export type CurrentSubscriptionResponse = {
  plan: SubscriptionPlanCode;
  planName: string;
  status: SubscriptionStatusCode;
  expiresAt: string | null;
  remainingDays: number | null;
  purchaseDate: string | null;
  renewalDate: string | null;
};

export type SubscriptionHistoryItem = {
  id: string;
  oldPlan: SubscriptionPlanCode;
  newPlan: SubscriptionPlanCode;
  event: string;
  metadata: Record<string, unknown> | null;
  createdAt: string;
};

export type CreateOrderResponse = {
  paymentUuid: string;
  razorpayOrderId: string;
  razorpayKey: string;
  amount: number;
  currency: string;
  businessName: string;
  ownerName: string;
  businessEmail: string;
  businessPhone: string;
};

export type CreateOrderInput = {
  businessId: string;
  plan: PurchasablePlan;
};

export type VerifyPaymentInput = {
  businessId: string;
  paymentUuid: string;
  razorpayOrderId: string;
  razorpayPaymentId: string;
  razorpaySignature: string;
};

export type VerifyPaymentResponse = {
  activated: boolean;
  plan: SubscriptionPlanCode;
  expiresAt: string;
};
