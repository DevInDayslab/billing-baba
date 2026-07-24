export const PURCHASABLE_PLANS = ['gold', 'platinum'] as const;

export type PurchasablePlan = (typeof PURCHASABLE_PLANS)[number];

export const SUBSCRIPTION_HISTORY_EVENTS = {
  PURCHASED: 'PURCHASED',
  UPGRADED: 'UPGRADED',
  RENEWED: 'RENEWED',
  EXPIRED: 'EXPIRED',
  DOWNGRADED: 'DOWNGRADED',
} as const;

export const RAZORPAY_WEBHOOK_EVENTS = {
  PAYMENT_CAPTURED: 'payment.captured',
  ORDER_PAID: 'order.paid',
} as const;

export const PLAN_DISPLAY_NAMES: Record<string, string> = {
  no_plan: 'No Plan',
  gold: 'Gold',
  platinum: 'Platinum',
};
