import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';

/// Rounds [amount] per Settings → Transaction → Round Off Total.
double applyTransactionRoundOff({
  required double amount,
  required bool enabled,
  required RoundOffMode mode,
  required int toValue,
}) {
  if (!enabled || toValue <= 0) return amount;
  final step = toValue.toDouble();
  final scaled = amount / step;
  final rounded = switch (mode) {
    RoundOffMode.nearest => scaled.round(),
    RoundOffMode.downTo => scaled.floor(),
    RoundOffMode.upTo => scaled.ceil(),
  };
  return rounded * step;
}

double transactionRoundOffDelta({
  required double rawTotal,
  required bool enabled,
  required RoundOffMode mode,
  required int toValue,
}) {
  final rounded = applyTransactionRoundOff(
    amount: rawTotal,
    enabled: enabled,
    mode: mode,
    toValue: toValue,
  );
  return rounded - rawTotal;
}
