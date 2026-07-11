enum PaymentMode { cash, upi, card, bank }

class PaymentEntry {
  const PaymentEntry({
    required this.mode,
    required this.amount,
  });

  final PaymentMode mode;
  final double amount;

  PaymentEntry copyWith({PaymentMode? mode, double? amount}) {
    return PaymentEntry(
      mode: mode ?? this.mode,
      amount: amount ?? this.amount,
    );
  }
}
