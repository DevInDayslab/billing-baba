import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview.dart';
import 'package:flutter/material.dart';

Widget buildDesktopPaymentWebView({
  required PaymentCheckoutConfig config,
  required PaymentWebViewMessageHandler onMessage,
  Key? key,
}) {
  return DesktopPaymentWebViewStub(
    key: key,
    config: config,
    onMessage: onMessage,
  );
}

class DesktopPaymentWebViewStub extends StatelessWidget {
  const DesktopPaymentWebViewStub({
    required this.config,
    required this.onMessage,
    super.key,
  });

  final PaymentCheckoutConfig config;
  final PaymentWebViewMessageHandler onMessage;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Embedded checkout is not supported on this platform.'),
    );
  }
}
