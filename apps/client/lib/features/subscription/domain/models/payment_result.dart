import 'package:billing_baba/features/subscription/domain/models/payment_outcome.dart';

/// Outcome returned by [MockPaymentService] after processing.
class PaymentResult {
  const PaymentResult({
    required this.outcome,
    required this.transactionId,
    required this.amount,
    this.failureMessage,
  });

  final PaymentOutcome outcome;
  final String transactionId;
  final double amount;
  final String? failureMessage;

  bool get isSuccess => outcome == PaymentOutcome.success;
  bool get isPending => outcome == PaymentOutcome.pending;
  bool get isFailed => outcome == PaymentOutcome.failed;
}
