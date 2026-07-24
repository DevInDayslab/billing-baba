import 'dart:async';
import 'dart:developer' as developer;

import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MacOSPaymentWebView extends StatefulWidget {
  const MacOSPaymentWebView({
    required this.config,
    required this.onMessage,
    super.key,
  });

  final PaymentCheckoutConfig config;
  final PaymentWebViewMessageHandler onMessage;

  @override
  State<MacOSPaymentWebView> createState() => _MacOSPaymentWebViewState();
}

class _MacOSPaymentWebViewState extends State<MacOSPaymentWebView> {
  late final WebViewController _controller;
  var _checkoutStarted = false;

  @override
  void initState() {
    super.initState();
    final params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
    );
    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PaymentBridge',
        onMessageReceived: (message) {
          handlePaymentWebViewMessage(message.message, widget.onMessage);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.prevent;
            }
            return isAllowedCheckoutNavigation(
                  uri,
                  isMainFrame: request.isMainFrame,
                )
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            unawaited(_startCheckout());
          },
        ),
      );

    if (kDebugMode) {
      unawaited(_enableWebViewInspection());
    }
    unawaited(_configureTransparentBackground());
    unawaited(_controller.loadFlutterAsset(checkoutAssetPath));
  }

  Future<void> _enableWebViewInspection() async {
    final platform = _controller.platform;
    if (platform is WebKitWebViewController) {
      try {
        await platform.setInspectable(true);
      } on Object catch (error) {
        developer.log(
          'WKWebView inspectable not available: $error',
          name: 'subscription.checkout',
        );
      }
    }
  }

  Future<void> _configureTransparentBackground() async {
    final platform = _controller.platform;
    if (platform is! WebKitWebViewController) {
      return;
    }
    try {
      await platform.setBackgroundColor(const Color(0x00000000));
    } on Object catch (error) {
      developer.log(
        'WKWebView setBackgroundColor unavailable on this platform: $error',
        name: 'subscription.checkout',
      );
    }
  }

  Future<void> _startCheckout() async {
    if (_checkoutStarted) {
      return;
    }
    _checkoutStarted = true;

    try {
      await _controller.runJavaScript(
        buildStartCheckoutJavaScript(widget.config),
      );
    } catch (error) {
      widget.onMessage({
        'event': 'payment_failed',
        'message': 'Could not start checkout.',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
