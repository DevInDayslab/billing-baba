import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Raw outcome from the Razorpay WebView bridge before server verification.
sealed class PaymentBridgeResult {
  const PaymentBridgeResult();
}

class PaymentBridgeCancelled extends PaymentBridgeResult {
  const PaymentBridgeCancelled();
}

class PaymentBridgeFailed extends PaymentBridgeResult {
  const PaymentBridgeFailed(this.message);

  final String message;
}

class PaymentBridgeSuccess extends PaymentBridgeResult {
  const PaymentBridgeSuccess({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
  });

  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;
}

class SubscriptionPaymentWebView extends StatefulWidget {
  const SubscriptionPaymentWebView({
    required this.order,
    required this.planType,
    required this.onResult,
    super.key,
  });

  final CreateOrderResult order;
  final SubscriptionPlanType planType;
  final ValueChanged<PaymentBridgeResult> onResult;

  @override
  State<SubscriptionPaymentWebView> createState() =>
      _SubscriptionPaymentWebViewState();
}

class _SubscriptionPaymentWebViewState extends State<SubscriptionPaymentWebView> {
  static const _initTimeout = Duration(seconds: 45);

  InAppWebViewController? _controller;
  String? _checkoutHtml;
  Timer? _initTimeoutTimer;
  var _checkoutStarted = false;
  var _completed = false;
  var _pageLoaded = false;
  var _paymentSucceeded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadHtml());
    _initTimeoutTimer = Timer(_initTimeout, () {
      if (!mounted || _completed || _checkoutStarted) return;
      _complete(
        const PaymentBridgeFailed('Checkout timed out. Please try again.'),
      );
    });
  }

  @override
  void dispose() {
    _initTimeoutTimer?.cancel();
    super.dispose();
  }

  String _desktopUserAgent() {
    if (Platform.isMacOS) {
      return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/120.0.0.0 Safari/537.36';
    }
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Safari/537.36';
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString('assets/checkout/checkout.html');
    if (!mounted) return;
    setState(() => _checkoutHtml = html);
  }

  void _handleBridgeMessage(String raw) {
    if (_completed) return;

    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      final event = payload['event'] as String? ?? '';
      final data = payload['data'] as Map<String, dynamic>? ?? {};

      switch (event) {
        case 'checkout_environment':
          debugPrint('[checkout] environment: $data');
        case 'razorpay_mobile_detection':
          debugPrint('[checkout] razorpay mobile detection: $data');
        case 'dom_inspection':
          debugPrint('[checkout] DOM inspection: $data');
        case 'payment_success':
          _paymentSucceeded = true;
          _initTimeoutTimer?.cancel();
          _complete(
            PaymentBridgeSuccess(
              razorpayPaymentId: data['razorpayPaymentId'] as String? ?? '',
              razorpayOrderId: data['razorpayOrderId'] as String? ?? '',
              razorpaySignature: data['razorpaySignature'] as String? ?? '',
            ),
          );
        case 'payment_failed':
          _initTimeoutTimer?.cancel();
          _complete(
            PaymentBridgeFailed(
              data['message'] as String? ?? 'Payment failed. Please try again.',
            ),
          );
        case 'payment_cancelled':
          _initTimeoutTimer?.cancel();
          _complete(const PaymentBridgeCancelled());
        case 'payment_modal_hidden':
          if (!_paymentSucceeded && !_completed) {
            _complete(const PaymentBridgeCancelled());
          }
        case 'payment_started':
          _initTimeoutTimer?.cancel();
        default:
          debugPrint('[checkout] unhandled bridge event: $event');
      }
    } on Object catch (error) {
      debugPrint('[checkout] bridge parse error: $error');
      if (!_completed) {
        _complete(
          const PaymentBridgeFailed(
            'Invalid checkout response. Please try again.',
          ),
        );
      }
    }
  }

  Future<void> _startCheckout() async {
    if (_checkoutStarted || _completed || _controller == null) return;
    _checkoutStarted = true;

    final order = widget.order;
    final config = {
      'key': order.razorpayKey,
      'orderId': order.razorpayOrderId,
      'amount': order.amount,
      'currency': order.currency,
      'businessName': order.businessName,
      'description': 'Vyapar ${widget.planType.displayName}',
      'themeColor': '#1565C0',
      'customerName': order.ownerName,
      'customerEmail': order.businessEmail,
      'customerPhone': order.businessPhone,
    };

    try {
      await _controller!.evaluateJavascript(
        source: 'BillingBabaCheckout.start(${jsonEncode(config)});',
      );
    } on Object catch (error) {
      debugPrint('[checkout] failed to start: $error');
      if (!_completed) {
        _complete(
          const PaymentBridgeFailed(
            'Failed to start checkout. Please try again.',
          ),
        );
      }
    }
  }

  void _complete(PaymentBridgeResult result) {
    if (_completed) return;
    _completed = true;
    _initTimeoutTimer?.cancel();
    widget.onResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final html = _checkoutHtml;
    if (html == null) {
      return const SizedBox.expand();
    }

    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: html,
        encoding: 'utf-8',
        baseUrl: WebUri('https://checkout.razorpay.com'),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptCanOpenWindowsAutomatically: true,
        supportMultipleWindows: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
        underPageBackgroundColor: const Color(0x00000000),
        userAgent: _desktopUserAgent(),
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
        controller.addJavaScriptHandler(
          handlerName: 'PaymentBridge',
          callback: (List<dynamic> args) {
            if (args.isEmpty) return null;
            final raw = args.first;
            if (raw is String) {
              _handleBridgeMessage(raw);
            } else if (raw != null) {
              _handleBridgeMessage(jsonEncode(raw));
            }
            return null;
          },
        );
      },
      onLoadStop: (controller, url) {
        debugPrint('[checkout] navigation finished: $url');
        if (_pageLoaded) return;
        _pageLoaded = true;
        unawaited(_startCheckout());
      },
      onReceivedError: (controller, request, error) {
        debugPrint(
          '[checkout] resource error: ${error.description} '
          'url=${request.url}',
        );
        if (_completed || _paymentSucceeded) return;
        _complete(
          PaymentBridgeFailed(
            error.description.isNotEmpty
                ? error.description
                : 'Failed to load checkout.',
          ),
        );
      },
      onConsoleMessage: (controller, message) {
        debugPrint('[checkout] console: ${message.message}');
      },
    );
  }
}
