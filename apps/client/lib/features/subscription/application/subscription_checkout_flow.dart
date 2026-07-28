import 'package:billing_baba/features/plans_pricing/presentation/desktop/widgets/payment_pending_dialog.dart';
import 'package:billing_baba/features/subscription/application/create_order_provider.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_view_provider.dart';
import 'package:billing_baba/features/subscription/application/purchase_history_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_error_mapper.dart';
import 'package:billing_baba/features/subscription/application/subscription_plans_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_service_provider.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/payment_bridge_result.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/subscription_payment_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Coordinates Razorpay checkout, server verification, and provider refresh.
class SubscriptionCheckoutFlow {
  const SubscriptionCheckoutFlow._();

  /// Starts checkout immediately and creates the Razorpay order in parallel.
  static Future<void> start(
    BuildContext context,
    WidgetRef ref, {
    required Future<CreateOrderResult?> orderFuture,
    required SubscriptionPlanType planType,
  }) async {
    final hostResult = await showSubscriptionPaymentHost(
      context,
      orderFuture: orderFuture,
      planType: planType,
      orderErrorMessage: () =>
          ref.read(createOrderControllerProvider.notifier).errorMessage(),
    );

    if (!context.mounted || hostResult == null) return;

    final order = hostResult.order;
    final bridgeResult = hostResult.payment;

    if (order == null) {
      final message = hostResult.orderErrorMessage ??
          switch (bridgeResult) {
            PaymentBridgeFailed(:final message) => message,
            _ => 'Unable to create payment order. Please try again.',
          };
      _showErrorSnackBar(context, message);
      return;
    }

    await _handlePaymentBridgeResult(
      context,
      ref,
      order: order,
      bridgeResult: bridgeResult,
    );
  }

  static Future<void> _handlePaymentBridgeResult(
    BuildContext context,
    WidgetRef ref, {
    required CreateOrderResult order,
    required PaymentBridgeResult bridgeResult,
  }) async {
    switch (bridgeResult) {
      case PaymentBridgeCancelled():
        return;
      case PaymentBridgeFailed(:final message):
        _showErrorSnackBar(context, message);
        return;
      case PaymentBridgeSuccess(
        :final razorpayPaymentId,
        :final razorpayOrderId,
        :final razorpaySignature,
      ):
        if (razorpayPaymentId.isEmpty ||
            razorpayOrderId.isEmpty ||
            razorpaySignature.isEmpty) {
          _showErrorSnackBar(
            context,
            'Incomplete payment response. Please try again.',
          );
          return;
        }

        try {
          final service = await ref.read(subscriptionServiceProvider.future);
          final verifyResult = await service.verifyPayment(
            paymentUuid: order.paymentUuid,
            razorpayOrderId: razorpayOrderId,
            razorpayPaymentId: razorpayPaymentId,
            razorpaySignature: razorpaySignature,
          );

          _refreshSubscriptionData(ref);

          if (!context.mounted) return;

          final formattedAmount =
              '₹${NumberFormat('#,##0.##', 'en_IN').format(order.amount / 100)}';

          await showPaymentSuccessDialog(
            context,
            planName: verifyResult.plan.displayName,
            expiresAt: verifyResult.expiresAt,
            amount: formattedAmount,
          );
        } on Object catch (error) {
          if (!context.mounted) return;
          _showErrorSnackBar(context, SubscriptionErrorMapper.messageFor(error));
        }
    }
  }

  static void _refreshSubscriptionData(WidgetRef ref) {
    ref
      ..invalidate(currentSubscriptionStateProvider)
      ..invalidate(purchaseHistoryStateProvider)
      ..invalidate(subscriptionPlansProvider)
      ..invalidate(plansPricingViewProvider);
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
