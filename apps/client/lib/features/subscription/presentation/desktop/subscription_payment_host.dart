import 'dart:async';
import 'dart:io' show Platform;

import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/subscription_payment_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';

const _panelWidth = 950.0;
const _panelHeight = 680.0;

/// Experiment switch between our custom WebView host and `razorpay_web`.
///
/// Default is [PaymentHostImplementation.razorpayWeb] for the desktop-layout
/// experiment. Flip back to [PaymentHostImplementation.customWebView] to restore
/// the previous host without deleting any code.
enum PaymentHostImplementation {
  customWebView,
  razorpayWeb,
}

/// Active payment host for this experiment.
const PaymentHostImplementation activePaymentHostImplementation =
    PaymentHostImplementation.razorpayWeb;

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
  return Navigator.of(context, rootNavigator: true).push<PaymentBridgeResult>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, _, _) {
        return PopScope(
          canPop: false,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: SizedBox(
                width: _panelWidth,
                height: _panelHeight,
                child: SubscriptionPaymentWebView(
                  order: order,
                  planType: planType,
                  onResult: (bridgeResult) {
                    Navigator.of(dialogContext).pop(bridgeResult);
                  },
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// Temporary adapter: maps `razorpay_web` events → [PaymentBridgeResult].
///
/// Package-specific APIs stay inside this file. Callers still receive the same
/// bridge result type used by the existing checkout flow.
Future<PaymentBridgeResult?> _showRazorpayWebHost(
  BuildContext context, {
  required CreateOrderResult order,
  required SubscriptionPlanType planType,
}) async {
  final media = MediaQuery.sizeOf(context);
  debugPrint(
    '[checkout] razorpay_web experiment: '
    'window=${media.width.toStringAsFixed(0)}x${media.height.toStringAsFixed(0)} '
    'packageDialogWidth=${media.width > 500 ? 480 : media.width - 32} '
    '(razorpay_web hardcodes 480px when screen width > 500)',
  );

  final completer = Completer<PaymentBridgeResult>();
  final razorpay = Razorpay();

  razorpay
    ..on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      if (completer.isCompleted) return;

      final paymentId = response.paymentId ?? '';
      final orderId = response.orderId ?? '';
      final signature = response.signature ?? '';

      debugPrint(
        '[checkout] razorpay_web success: '
        'paymentId=${paymentId.isEmpty ? "<empty>" : paymentId} '
        'orderId=${orderId.isEmpty ? "<empty>" : orderId} '
        'signature=${signature.isEmpty ? "<empty>" : "<present>"}',
      );

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

      debugPrint(
        '[checkout] razorpay_web error: code=${response.code} '
        'message=${response.message}',
      );

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
