import 'dart:math';

import 'package:billing_baba/features/subscription/domain/models/payment_outcome.dart';
import 'package:billing_baba/features/subscription/domain/models/payment_result.dart';

/// Frontend-only payment processor that simulates Cashfree-style latency.
class MockPaymentService {
  const MockPaymentService();

  static const supportPhoneNumber = '1800-309-8855';

  static const _minDelayMs = 2000;
  static const _maxDelayMs = 4000;

  Future<PaymentResult> processPayment({
    required double amount,
    PaymentOutcome? debugOutcome,
  }) async {
    final random = Random();
    final delayMs =
        _minDelayMs + random.nextInt(_maxDelayMs - _minDelayMs + 1);
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    final outcome = debugOutcome ?? _randomOutcome(random);
    final transactionId = _generateTransactionId(random);

    return PaymentResult(
      outcome: outcome,
      transactionId: transactionId,
      amount: amount,
      failureMessage: outcome == PaymentOutcome.failed
          ? 'Payment was declined by your bank. Please try again.'
          : null,
    );
  }

  PaymentOutcome _randomOutcome(Random random) {
    final roll = random.nextDouble();
    if (roll < 0.65) return PaymentOutcome.success;
    if (roll < 0.85) return PaymentOutcome.pending;
    return PaymentOutcome.failed;
  }

  String _generateTransactionId(Random random) {
    final suffix = random.nextInt(9000000) + 1000000;
    return 'CF${DateTime.now().millisecondsSinceEpoch}$suffix';
  }
}
