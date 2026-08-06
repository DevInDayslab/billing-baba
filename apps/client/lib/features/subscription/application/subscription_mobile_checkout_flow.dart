import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/features/payments/data/razorpay_checkout_gateway.dart';
import 'package:billing_baba/features/payments/domain/models/payment_models.dart'
    hide PaymentResult;
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_view_provider.dart';
import 'package:billing_baba/features/subscription/application/purchase_history_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_busy_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session.dart';
import 'package:billing_baba/features/subscription/application/subscription_create_order_mapper.dart';
import 'package:billing_baba/features/subscription/application/subscription_error_mapper.dart';
import 'package:billing_baba/features/subscription/application/subscription_plans_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_service_provider.dart';
import 'package:billing_baba/features/subscription/domain/models/payment_outcome.dart';
import 'package:billing_baba/features/subscription/domain/models/payment_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionMobileCheckoutResult {
  const SubscriptionMobileCheckoutResult({
    required this.outcome,
    this.result,
    this.errorMessage,
    this.pendingCredentials,
  });

  final PaymentOutcome outcome;
  final PaymentResult? result;
  final String? errorMessage;
  final SubscriptionPendingPaymentCredentials? pendingCredentials;
}

class SubscriptionPendingPaymentCredentials {
  const SubscriptionPendingPaymentCredentials({
    required this.paymentUuid,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.amountPaise,
  });

  final String paymentUuid;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final int amountPaise;
}

/// Native Razorpay subscription checkout for Android/iOS.
class SubscriptionMobileCheckoutFlow {
  const SubscriptionMobileCheckoutFlow(this._ref);

  final Ref _ref;

  Future<SubscriptionMobileCheckoutResult> process(
    SubscriptionCheckoutSession session,
  ) async {
    final planType = session.input.planType;
    if (!planType.isPurchasable) {
      return const SubscriptionMobileCheckoutResult(
        outcome: PaymentOutcome.failed,
        errorMessage: 'Selected plan is not available for purchase.',
      );
    }

    if (!AppConfig.razorpayNative || !RazorpayCheckoutGateway.isSupported) {
      return const SubscriptionMobileCheckoutResult(
        outcome: PaymentOutcome.failed,
        errorMessage: 'Razorpay checkout is not available on this device.',
      );
    }

    _ref.read(subscriptionCheckoutBusyProvider.notifier).begin();
    final gateway = RazorpayCheckoutGateway();

    try {
      final service = await _ref.read(subscriptionServiceProvider.future);
      final order = await service.createOrder(planType);

      final callback = await gateway.openCheckout(
        order: order.toGatewayOrderResult(),
        notes: {
          'payment_uuid': order.paymentUuid,
          'plan': planType.apiValue,
        },
      );

      if (callback == null) {
        return const SubscriptionMobileCheckoutResult(
          outcome: PaymentOutcome.failed,
          errorMessage: 'Payment was cancelled.',
        );
      }

      if (callback.paymentId.isEmpty ||
          callback.orderId.isEmpty ||
          callback.signature.isEmpty) {
        return const SubscriptionMobileCheckoutResult(
          outcome: PaymentOutcome.failed,
          errorMessage: 'Incomplete payment response. Please try again.',
        );
      }

      final credentials = SubscriptionPendingPaymentCredentials(
        paymentUuid: order.paymentUuid,
        razorpayOrderId: callback.orderId,
        razorpayPaymentId: callback.paymentId,
        razorpaySignature: callback.signature,
        amountPaise: order.amount,
      );

      try {
        return await _verifyAndComplete(
          credentials: credentials,
          amountPaise: order.amount,
        );
      } on Object catch (error) {
        return SubscriptionMobileCheckoutResult(
          outcome: PaymentOutcome.pending,
          errorMessage: SubscriptionErrorMapper.messageFor(error),
          pendingCredentials: credentials,
          result: PaymentResult(
            outcome: PaymentOutcome.pending,
            transactionId: credentials.razorpayPaymentId,
            amount: order.amount / 100,
          ),
        );
      }
    } on PaymentFailure catch (error) {
      return SubscriptionMobileCheckoutResult(
        outcome: PaymentOutcome.failed,
        errorMessage: error.message,
      );
    } on Object catch (error) {
      return SubscriptionMobileCheckoutResult(
        outcome: PaymentOutcome.failed,
        errorMessage: SubscriptionErrorMapper.messageFor(error),
      );
    } finally {
      gateway.dispose();
      _ref.read(subscriptionCheckoutBusyProvider.notifier).end();
    }
  }

  Future<SubscriptionMobileCheckoutResult> retryVerification(
    SubscriptionPendingPaymentCredentials credentials,
  ) async {
    _ref.read(subscriptionCheckoutBusyProvider.notifier).begin();
    try {
      return await _verifyAndComplete(
        credentials: credentials,
        amountPaise: credentials.amountPaise,
      );
    } on Object catch (error) {
      return SubscriptionMobileCheckoutResult(
        outcome: PaymentOutcome.pending,
        errorMessage: SubscriptionErrorMapper.messageFor(error),
        pendingCredentials: credentials,
      );
    } finally {
      _ref.read(subscriptionCheckoutBusyProvider.notifier).end();
    }
  }

  Future<SubscriptionMobileCheckoutResult> _verifyAndComplete({
    required SubscriptionPendingPaymentCredentials credentials,
    required int amountPaise,
  }) async {
    final service = await _ref.read(subscriptionServiceProvider.future);
    final verifyResult = await service.verifyPayment(
      paymentUuid: credentials.paymentUuid,
      razorpayOrderId: credentials.razorpayOrderId,
      razorpayPaymentId: credentials.razorpayPaymentId,
      razorpaySignature: credentials.razorpaySignature,
    );

    _refreshSubscriptionData();

    return SubscriptionMobileCheckoutResult(
      outcome: PaymentOutcome.success,
      result: PaymentResult(
        outcome: PaymentOutcome.success,
        transactionId: credentials.razorpayPaymentId,
        amount: amountPaise / 100,
        verifyResult: verifyResult,
      ),
    );
  }

  void _refreshSubscriptionData() {
    _ref
      ..invalidate(currentSubscriptionStateProvider)
      ..invalidate(purchaseHistoryStateProvider)
      ..invalidate(subscriptionPlansProvider)
      ..invalidate(plansPricingViewProvider);
  }
}
