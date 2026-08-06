import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/subscription/application/mock_payment_service.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_mobile_checkout_flow.dart';
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
    this.pendingCredentials,
  });

  final PaymentStatus status;
  final PaymentResult? result;
  final String? errorMessage;
  final SubscriptionPendingPaymentCredentials? pendingCredentials;

  bool get isLoading => status == PaymentStatus.loading;
  bool get isProcessing => status == PaymentStatus.loading;

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentResult? result,
    String? errorMessage,
    SubscriptionPendingPaymentCredentials? pendingCredentials,
    bool clearResult = false,
    bool clearError = false,
    bool clearPendingCredentials = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingCredentials: clearPendingCredentials
          ? null
          : (pendingCredentials ?? this.pendingCredentials),
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

  bool get _useMockPayment =>
      AppConfig.subscriptionMockPayment &&
      ref.read(mockPaymentDebugOutcomeProvider) != null;

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

    state = state.copyWith(
      status: PaymentStatus.loading,
      clearResult: true,
      clearError: true,
      clearPendingCredentials: true,
    );

    if (_useMockPayment) {
      return _processMockPayment(session);
    }

    final checkout = SubscriptionMobileCheckoutFlow(ref);
    final checkoutResult = await checkout.process(session);

    ref
        .read(subscriptionCheckoutSessionProvider.notifier)
        .recordTransactionId(checkoutResult.result?.transactionId);

    if (checkoutResult.pendingCredentials != null) {
      ref
          .read(subscriptionCheckoutSessionProvider.notifier)
          .recordPendingPayment(checkoutResult.pendingCredentials!);
    }

    state = _stateForCheckoutResult(checkoutResult);
    return checkoutResult.result;
  }

  Future<PaymentResult?> retryStatusCheck() async {
    final session = ref.read(subscriptionCheckoutSessionProvider);
    if (session == null) return null;

    final credentials =
        state.pendingCredentials ?? session.pendingPaymentCredentials;
    if (credentials == null) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'No pending payment to verify. Please try again.',
      );
      return null;
    }

    state = state.copyWith(status: PaymentStatus.loading, clearError: true);

    final checkout = SubscriptionMobileCheckoutFlow(ref);
    final checkoutResult = await checkout.retryVerification(credentials);

    ref
        .read(subscriptionCheckoutSessionProvider.notifier)
        .recordTransactionId(checkoutResult.result?.transactionId);

    state = _stateForCheckoutResult(checkoutResult);
    return checkoutResult.result;
  }

  Future<PaymentResult?> _processMockPayment(
    SubscriptionCheckoutSession session,
  ) async {
    final pricing = SubscriptionOrderPricing.calculate(
      input: session.input,
      couponDiscountOnTaxable: session.couponDiscountOnTaxable,
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

      state = _stateForMockResult(result, session);
      return result;
    } on Object {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Payment could not be processed. Please try again.',
      );
      return null;
    }
  }

  PaymentState _stateForCheckoutResult(
    SubscriptionMobileCheckoutResult checkoutResult,
  ) {
    return switch (checkoutResult.outcome) {
      PaymentOutcome.success => PaymentState(
        status: PaymentStatus.success,
        result: checkoutResult.result,
      ),
      PaymentOutcome.pending => PaymentState(
        status: PaymentStatus.pending,
        result: checkoutResult.result,
        errorMessage: checkoutResult.errorMessage,
        pendingCredentials: checkoutResult.pendingCredentials,
      ),
      PaymentOutcome.failed => PaymentState(
        status: PaymentStatus.failed,
        result: checkoutResult.result,
        errorMessage:
            checkoutResult.errorMessage ??
            checkoutResult.result?.failureMessage ??
            'Payment could not be processed. Please try again.',
      ),
    };
  }

  PaymentState _stateForMockResult(
    PaymentResult result,
    SubscriptionCheckoutSession session,
  ) {
    return switch (result.outcome) {
      PaymentOutcome.success => PaymentState(
        status: PaymentStatus.success,
        result: result,
      ),
      PaymentOutcome.pending => PaymentState(
        status: PaymentStatus.pending,
        result: result,
      ),
      PaymentOutcome.failed => PaymentState(
        status: PaymentStatus.failed,
        result: result,
      ),
    };
  }
}
