export const GATEWAY_WEBHOOK_EVENTS = {
  PAYMENT_AUTHORIZED: 'payment.authorized',
  PAYMENT_CAPTURED: 'payment.captured',
  PAYMENT_FAILED: 'payment.failed',
  ORDER_PAID: 'order.paid',
  REFUND_CREATED: 'refund.created',
  REFUND_PROCESSED: 'refund.processed',
} as const;

export const RECEIVED_INTENT_TYPES = [
  'payment_in',
  'sale_invoice',
  'pos',
  'party_outstanding',
  'advance',
] as const;

export const PAID_INTENT_TYPES = ['payment_out', 'purchase_bill'] as const;
