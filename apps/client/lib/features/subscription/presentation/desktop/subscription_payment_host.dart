import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/payment_bridge_result.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/subscription_razorpay_desktop_checkout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'package:billing_baba/features/subscription/presentation/desktop/payment_bridge_result.dart';

/// Presents Razorpay Standard Checkout on desktop via our InAppWebView host.
Future<PaymentBridgeResult?> showSubscriptionPaymentHost(
  BuildContext context, {
  required CreateOrderResult order,
  required SubscriptionPlanType planType,
}) async {
  final platform = AppPlatform.current;
  if (kIsWeb || (!platform.isMacOS && !platform.isWindows)) {
    return const PaymentBridgeFailed(
      'Payments are only supported on desktop.',
    );
  }

  final options = <String, dynamic>{
    'key': order.razorpayKey,
    'amount': order.amount,
    'currency': order.currency,
    'order_id': order.razorpayOrderId,
    'name': order.businessName,
    'description': 'Vyapar ${planType.displayName}',
    'prefill': {
      'name': order.ownerName,
      'email': order.businessEmail,
      'contact': order.businessPhone,
    },
    'theme': {'color': '#1565C0'},
  };

  try {
    return await showRazorpayDesktopCheckout(context, options: options);
  } on Object catch (error) {
    debugPrint('[checkout] open failed: $error');
    return PaymentBridgeFailed('Failed to open checkout: $error');
  }
}
