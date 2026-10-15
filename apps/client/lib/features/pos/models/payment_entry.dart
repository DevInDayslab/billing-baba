enum PaymentMode { cash, upi, card, bank }

class PaymentEntry {
  const PaymentEntry({
    required this.mode,
    required this.amount,
    this.bankAccountId,
  });

  final PaymentMode mode;
  final double amount;
  final String? bankAccountId;

  PaymentEntry copyWith({
    PaymentMode? mode,
    double? amount,
    String? bankAccountId,
  }) {
    return PaymentEntry(
      mode: mode ?? this.mode,
      amount: amount ?? this.amount,
      bankAccountId: bankAccountId ?? this.bankAccountId,
    );
  }
}
