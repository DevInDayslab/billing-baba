import 'package:billing_baba/features/subscription/domain/models/payment_outcome.dart';
import 'package:billing_baba/features/subscription/domain/models/verify_payment_result.dart';

/// Outcome returned after subscription payment processing.
class PaymentResult {
  const PaymentResult({
    required this.outcome,
    required this.transactionId,
    required this.amount,
    this.failureMessage,
    this.verifyResult,
  });

  final PaymentOutcome outcome;
  final String transactionId;
  final double amount;
  final String? failureMessage;
  final VerifyPaymentResult? verifyResult;

  bool get isSuccess => outcome == PaymentOutcome.success;
  bool get isPending => outcome == PaymentOutcome.pending;
  bool get isFailed => outcome == PaymentOutcome.failed;
}
