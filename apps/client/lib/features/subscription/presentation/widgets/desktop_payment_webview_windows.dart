import 'dart:async';
import 'dart:convert';

import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_windows/webview_flutter_windows.dart';

class WindowsPaymentWebView extends StatefulWidget {
  const WindowsPaymentWebView({
    required this.config,
    required this.onMessage,
    super.key,
  });

  final PaymentCheckoutConfig config;
  final PaymentWebViewMessageHandler onMessage;

  @override
  State<WindowsPaymentWebView> createState() => _WindowsPaymentWebViewState();
}

class _WindowsPaymentWebViewState extends State<WindowsPaymentWebView> {
  final _controller = WebviewController();
  StreamSubscription<dynamic>? _messageSubscription;
  StreamSubscription<LoadingState>? _loadingSubscription;
  var _initialized = false;
  var _checkoutStarted = false;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      final version = await WebviewController.getWebViewVersion();
      if (version == null) {
        widget.onMessage({
          'event': 'payment_failed',
          'message': 'WebView2 runtime is not installed on this device.',
        });
        return;
      }

      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      _messageSubscription = _controller.webMessage.listen((message) {
        final raw = message is String ? message : jsonEncode(message);
        handlePaymentWebViewMessage(raw, widget.onMessage);
      });

      _loadingSubscription = _controller.loadingState.listen((state) {
        if (state == LoadingState.navigationCompleted) {
          unawaited(_startCheckout());
        }
      });

      final html = await rootBundle.loadString(checkoutAssetPath);
      await _controller.loadStringContent(html);
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (error) {
      widget.onMessage({
        'event': 'payment_failed',
        'message': error.toString(),
      });
    }
  }

  Future<void> _startCheckout() async {
    if (_checkoutStarted) {
      return;
    }
    _checkoutStarted = true;

    try {
      await _controller.executeScript(
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
  void dispose() {
    unawaited(_messageSubscription?.cancel());
    unawaited(_loadingSubscription?.cancel());
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.expand();
    }

    return Webview(_controller);
  }
}
