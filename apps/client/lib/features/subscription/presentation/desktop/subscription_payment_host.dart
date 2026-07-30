import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/payment_bridge_result.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/subscription_razorpay_desktop_checkout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/features/subscription/presentation/desktop/payment_bridge_result.dart';
export 'package:billing_baba/features/subscription/presentation/desktop/subscription_razorpay_desktop_checkout.dart'
    show SubscriptionPaymentHostResult;

/// Presents Razorpay Standard Checkout on desktop via our InAppWebView host.
///
/// Opens the checkout shell immediately and resolves [orderFuture] inside it so
/// Razorpay can open while the host dialog is already on screen.
Future<SubscriptionPaymentHostResult?> showSubscriptionPaymentHost(
  BuildContext context, {
  required Future<CreateOrderResult?> orderFuture,
  required SubscriptionPlanType planType,
  required String? Function() orderErrorMessage,
}) async {
  final platform = AppPlatform.current;
  if (kIsWeb || (!platform.isMacOS && !platform.isWindows)) {
    return SubscriptionPaymentHostResult(
      payment: const PaymentBridgeFailed(
        'Payments are only supported on desktop.',
      ),
    );
  }

  try {
    return await showRazorpayDesktopCheckout(
      context,
      orderFuture: orderFuture,
      planType: planType,
      orderErrorMessage: orderErrorMessage,
    );
  } on Object catch (error) {
    debugPrint('[checkout] open failed: $error');
    return SubscriptionPaymentHostResult(
      payment: PaymentBridgeFailed('Failed to open checkout: $error'),
    );
  }
}
