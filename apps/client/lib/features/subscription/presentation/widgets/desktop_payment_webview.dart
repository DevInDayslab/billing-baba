import 'dart:convert';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_helper.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview_stub.dart'
    if (dart.library.io) 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview_io.dart' as platform;
import 'package:flutter/material.dart';

typedef PaymentWebViewMessageHandler = void Function(Map<String, dynamic> message);

typedef PaymentCheckoutConfig = Map<String, dynamic>;

const checkoutAssetPath = 'assets/checkout/checkout.html';

PaymentCheckoutConfig buildCheckoutConfig({
  required CreateOrderResponseModel order,
  required String planName,
}) {
  return {
    'razorpayKey': order.razorpayKey,
    'razorpayOrderId': order.razorpayOrderId,
    'amount': order.amount,
    'currency': order.currency,
    'businessName': order.businessName,
    'prefillName': order.ownerName.trim(),
    'prefillEmail': order.businessEmail.trim(),
    'prefillContact': formatRazorpayContact(order.businessPhone),
    'description': planName,
    'themeColor': _colorToHex(AppColors.error),
  };
}

String _colorToHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
}

String buildStartCheckoutJavaScript(PaymentCheckoutConfig config) {
  return 'window.BillingBabaCheckout.start(${jsonEncode(config)});';
}

bool isAllowedCheckoutNavigation(Uri uri, {required bool isMainFrame}) {
  final scheme = uri.scheme.toLowerCase();
  if (scheme == 'file' || scheme == 'about' || scheme == 'data') {
    return true;
  }

  final host = uri.host.toLowerCase();
  if (host.contains('razorpay.com') || host.contains('razorpay.in')) {
    return !isMainFrame;
  }

  return !isMainFrame;
}

Widget buildDesktopPaymentWebView({
  required PaymentCheckoutConfig config,
  required PaymentWebViewMessageHandler onMessage,
  Key? key,
}) {
  return platform.buildDesktopPaymentWebView(
    key: key,
    config: config,
    onMessage: onMessage,
  );
}
