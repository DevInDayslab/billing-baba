import 'dart:convert';
import 'dart:io' show Platform;

import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview_macos.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview_stub.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview_windows.dart';
import 'package:flutter/material.dart';

Widget buildDesktopPaymentWebView({
  required PaymentCheckoutConfig config,
  required PaymentWebViewMessageHandler onMessage,
  Key? key,
}) {
  if (Platform.isMacOS) {
    return MacOSPaymentWebView(key: key, config: config, onMessage: onMessage);
  }
  if (Platform.isWindows) {
    return WindowsPaymentWebView(key: key, config: config, onMessage: onMessage);
  }
  return DesktopPaymentWebViewStub(key: key, config: config, onMessage: onMessage);
}

void handlePaymentWebViewMessage(
  String raw,
  PaymentWebViewMessageHandler onMessage,
) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      onMessage(decoded);
      return;
    }
    if (decoded is Map) {
      onMessage(decoded.map((key, value) => MapEntry(key.toString(), value)));
    }
  } on Object {
    onMessage({'event': 'payment_failed', 'message': 'Invalid bridge message'});
  }
}
