import 'package:billing_baba/features/subscription/application/mock_payment_service.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_local_activation.dart';
import 'package:billing_baba/features/subscription/application/subscription_order_pricing.dart';
import 'package:billing_baba/features/subscription/domain/models/payment_outcome.dart';
import 'package:billing_baba/features/subscription/domain/models/payment_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentStatus {
  idle,
  loading,
  success,
  pending,
  failed,
}

class PaymentState {
  const PaymentState({
    this.status = PaymentStatus.idle,
    this.result,
    this.errorMessage,
  });

  final PaymentStatus status;
  final PaymentResult? result;
  final String? errorMessage;

  bool get isLoading => status == PaymentStatus.loading;
  bool get isProcessing => status == PaymentStatus.loading;

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Optional debug override for mock payment outcomes (success / pending / failed).
final mockPaymentDebugOutcomeProvider =
    NotifierProvider<MockPaymentDebugOutcomeNotifier, PaymentOutcome?>(
  MockPaymentDebugOutcomeNotifier.new,
);

class MockPaymentDebugOutcomeNotifier extends Notifier<PaymentOutcome?> {
  @override
  PaymentOutcome? build() => null;

  void set(PaymentOutcome? outcome) => state = outcome;
}

final Provider<MockPaymentService> mockPaymentServiceProvider = Provider(
  (ref) => const MockPaymentService(),
);

final paymentStateProvider =
    NotifierProvider<PaymentStateNotifier, PaymentState>(
  PaymentStateNotifier.new,
);

class PaymentStateNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  void reset() {
    state = const PaymentState();
  }

  Future<PaymentResult?> processPayment() async {
    if (state.isLoading) return null;

    final session = ref.read(subscriptionCheckoutSessionProvider);
    if (session == null) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Checkout session expired. Please try again.',
      );
      return null;
    }

    final pricing = SubscriptionOrderPricing.calculate(
      input: session.input,
      couponDiscountOnTaxable: session.couponDiscountOnTaxable,
    );

    state = state.copyWith(
      status: PaymentStatus.loading,
      clearResult: true,
      clearError: true,
    );

    final debugOutcome = ref.read(mockPaymentDebugOutcomeProvider);
    final paymentService = ref.read(mockPaymentServiceProvider);

    try {
      final result = await paymentService.processPayment(
        amount: pricing.total,
        debugOutcome: debugOutcome,
      );

      ref
          .read(subscriptionCheckoutSessionProvider.notifier)
          .recordTransactionId(result.transactionId);

      state = _stateForResult(result, session);
      return result;
    } on Object {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Payment could not be processed. Please try again.',
      );
      return null;
    }
  }

  Future<PaymentResult?> retryStatusCheck() async {
    final session = ref.read(subscriptionCheckoutSessionProvider);
    if (session == null) return null;

    state = state.copyWith(status: PaymentStatus.loading, clearError: true);

    final debugOutcome =
        ref.read(mockPaymentDebugOutcomeProvider) ?? PaymentOutcome.success;
    final pricing = SubscriptionOrderPricing.calculate(
      input: session.input,
      couponDiscountOnTaxable: session.couponDiscountOnTaxable,
    );

    final paymentService = ref.read(mockPaymentServiceProvider);
    final result = await paymentService.processPayment(
      amount: pricing.total,
      debugOutcome: debugOutcome,
    );

    ref
        .read(subscriptionCheckoutSessionProvider.notifier)
        .recordTransactionId(result.transactionId);

    state = _stateForResult(result, session);
    return result;
  }

  PaymentState _stateForResult(
    PaymentResult result,
    SubscriptionCheckoutSession session,
  ) {
    return switch (result.outcome) {
      PaymentOutcome.success => () {
          activateLocalSubscription(ref, session: session);
          return PaymentState(status: PaymentStatus.success, result: result);
        }(),
      PaymentOutcome.pending =>
        PaymentState(status: PaymentStatus.pending, result: result),
      PaymentOutcome.failed =>
        PaymentState(status: PaymentStatus.failed, result: result),
    };
  }
}
