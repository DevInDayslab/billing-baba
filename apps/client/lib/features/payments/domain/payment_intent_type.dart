/// Gateway payment intent types supported by `/api/v1/payments`.
enum PaymentIntentType {
  paymentIn('payment_in'),
  paymentOut('payment_out'),
  saleInvoice('sale_invoice'),
  purchaseBill('purchase_bill'),
  pos('pos'),
  partyOutstanding('party_outstanding'),
  advance('advance');

  const PaymentIntentType(this.apiValue);
  final String apiValue;
}

/// Client-side payment flow state machine.
enum PaymentFlowState {
  idle,
  creatingOrder,
  launchingCheckout,
  waitingVerification,
  verified,
  failed,
  cancelled,
  pending,
  expired,
  recovered,
}
