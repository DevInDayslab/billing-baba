/// How to route a shortfall when paid amount is less than the target total.
enum ShortPaymentHandling {
  /// Keep the shortfall on the official party receivable (default).
  officialDue('official_balance'),

  /// Record the shortfall in the seller-only hidden ledger.
  hiddenLedger('unrecovered');

  const ShortPaymentHandling(this.apiValue);

  final String apiValue;
}
