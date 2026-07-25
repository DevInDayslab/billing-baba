import 'dart:async';
import 'dart:io' show Platform;

import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/subscription_payment_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';

/// Experiment switch between our custom WebView host and `razorpay_web`.
///
/// Prefer [PaymentHostImplementation.customWebView]. `razorpay_web` hardcodes
/// a 480px dialog (mobile checkout) on wide screens.
enum PaymentHostImplementation {
  customWebView,
  razorpayWeb,
}

const PaymentHostImplementation activePaymentHostImplementation =
    PaymentHostImplementation.customWebView;

/// Flutter scrim only — Razorpay paints its own desktop modal on top.
const _checkoutBarrierColor = Color(0x99000000);

/// Presents Razorpay checkout. Public API is unchanged for callers.
Future<PaymentBridgeResult?> showSubscriptionPaymentHost(
  BuildContext context, {
  required CreateOrderResult order,
  required SubscriptionPlanType planType,
}) {
  if (kIsWeb || (!Platform.isMacOS && !Platform.isWindows)) {
    return Future.value(
      const PaymentBridgeFailed('Payments are only supported on desktop.'),
    );
  }

  return switch (activePaymentHostImplementation) {
    PaymentHostImplementation.customWebView =>
      _showCustomWebViewHost(context, order: order, planType: planType),
    PaymentHostImplementation.razorpayWeb =>
      _showRazorpayWebHost(context, order: order, planType: planType),
  };
}

Future<PaymentBridgeResult?> _showCustomWebViewHost(
  BuildContext context, {
  required CreateOrderResult order,
  required SubscriptionPlanType planType,
}) {
  final size = MediaQuery.sizeOf(context);
  debugPrint(
    '[checkout] full-window host '
    '${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)} '
    '(no parent embed — standard desktop modal)',
  );

  // Full-window transparent WebView so window.innerWidth is the real desktop
  // width. A fixed 960 panel + `parent` was still rendering Razorpay's compact
  // (mobile) embed UI even when innerWidth reported 960.
  return showGeneralDialog<PaymentBridgeResult>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Checkout',
    barrierColor: _checkoutBarrierColor,
    pageBuilder: (dialogContext, _, _) {
      return PopScope(
        canPop: false,
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox.expand(
            child: SubscriptionPaymentWebView(
              order: order,
              planType: planType,
              onResult: (bridgeResult) {
                Navigator.of(dialogContext).pop(bridgeResult);
              },
            ),
          ),
        ),
      );
    },
  );
}

/// Temporary adapter: maps `razorpay_web` events → [PaymentBridgeResult].
Future<PaymentBridgeResult?> _showRazorpayWebHost(
  BuildContext context, {
  required CreateOrderResult order,
  required SubscriptionPlanType planType,
}) async {
  final media = MediaQuery.sizeOf(context);
  debugPrint(
    '[checkout] razorpay_web experiment: '
    'window=${media.width.toStringAsFixed(0)}x${media.height.toStringAsFixed(0)} '
    'packageDialogWidth=${media.width > 500 ? 480 : media.width - 32}',
  );

  final completer = Completer<PaymentBridgeResult>();
  final razorpay = Razorpay()

  
    ..on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      if (completer.isCompleted) return;

      final paymentId = response.paymentId ?? '';
      final orderId = response.orderId ?? '';
      final signature = response.signature ?? '';

      if (paymentId.isEmpty || orderId.isEmpty || signature.isEmpty) {
        completer.complete(
          const PaymentBridgeFailed(
            'Incomplete payment response from Razorpay.',
          ),
        );
        return;
      }

      completer.complete(
        PaymentBridgeSuccess(
          razorpayPaymentId: paymentId,
          razorpayOrderId: orderId,
          razorpaySignature: signature,
        ),
      );
    })
    ..on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      if (completer.isCompleted) return;

      if (response.code == Razorpay.PAYMENT_CANCELLED) {
        completer.complete(const PaymentBridgeCancelled());
        return;
      }

      completer.complete(
        PaymentBridgeFailed(
          response.message?.isNotEmpty == true
              ? response.message!
              : 'Payment failed. Please try again.',
        ),
      );
    });

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
    razorpay.open(options, context: context);
    return await completer.future;
  } on Object catch (error) {
    debugPrint('[checkout] razorpay_web open failed: $error');
    return PaymentBridgeFailed('Failed to open checkout: $error');
  } finally {
    razorpay.clear();
  }
}
