import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  static const _minDesktopWidth = 768.0;

  WebViewController? _controller;
  Timer? _initTimeoutTimer;
  var _checkoutStarted = false;
  var _completed = false;
  var _pageLoaded = false;
  var _layoutReady = false;
  var _paymentSucceeded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initWebView());
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

  WebViewController _createController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        javaScriptCanOpenWindowsAutomatically: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PaymentBridge',
        onMessageReceived: _handleBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            debugPrint('[checkout] navigation finished: $url');
            _pageLoaded = true;
            _maybeStartCheckout();
          },
          onUrlChange: (change) {
            debugPrint('[checkout] url change: ${change.url}');
          },
          onNavigationRequest: (request) {
            debugPrint('[checkout] navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint(
              '[checkout] resource error: ${error.description} '
              '(${error.errorCode}) url=${error.url}',
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
        ),
      );

    return controller;
  }

  Future<void> _initWebView() async {
    final html = await rootBundle.loadString('assets/checkout/checkout.html');
    if (!mounted) return;

    final controller = _createController();

    // macOS: never call setBackgroundColor — WKWebView throws on opacity.
    // Windows: use opaque white, not transparent.
    if (Platform.isWindows) {
      await controller.setBackgroundColor(AppColors.surface);
    }

    await controller.setUserAgent(_desktopUserAgent());
    await controller.loadHtmlString(
      html,
      baseUrl: 'https://checkout.razorpay.com',
    );

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  void _handleBridgeMessage(JavaScriptMessage message) {
    if (_completed) return;

    try {
      final payload = jsonDecode(message.message) as Map<String, dynamic>;
      final event = payload['event'] as String? ?? '';
      final data = payload['data'] as Map<String, dynamic>? ?? {};

      switch (event) {
        case 'checkout_environment':
          debugPrint('[checkout] environment: $data');
          _logMobileCheckoutDiagnosis(data);
        case 'razorpay_mobile_detection':
          debugPrint('[checkout] razorpay mobile detection: $data');
        case 'dom_inspection':
          _logDomInspection(data);
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
          debugPrint('[checkout] razorpay modal hidden (paymentSucceeded=$_paymentSucceeded)');
          if (!_paymentSucceeded && !_completed) {
            _complete(const PaymentBridgeCancelled());
          }
        case 'payment_started':
          _initTimeoutTimer?.cancel();
        case 'viewport_metrics':
          break;
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

  void _logDomInspection(Map<String, dynamic> data) {
    final stage = data['stage'] as String? ?? 'unknown';
    debugPrint('[checkout] DOM inspection @$stage');

    final ancestors = data['ancestors'] as List<dynamic>? ?? [];
    for (final raw in ancestors) {
      final node = raw as Map<String, dynamic>;
      debugPrint(
        '  [${node['label']}] bg=${node['backgroundColor']} '
        'size=${node['rectWidth']}x${node['rectHeight']} '
        'display=${node['display']}',
      );
    }

    final razorpayNodes = data['razorpayNodes'] as List<dynamic>? ?? [];
    for (final raw in razorpayNodes) {
      final node = raw as Map<String, dynamic>;
      debugPrint(
        '  [${node['label']}] bg=${node['backgroundColor']} '
        'size=${node['rectWidth']}x${node['rectHeight']} '
        'tag=${node['tag']} class=${node['className']}',
      );
    }
  }

  void _logMobileCheckoutDiagnosis(Map<String, dynamic> env) {
    final stage = env['stage'] as String? ?? 'unknown';
    final innerWidth = (env['innerWidth'] as num?)?.toDouble() ?? 0;
    final mobileMedia = env['mobileMedia'] == true;
    final maxDeviceWidth485 = env['maxDeviceWidth485'] == true;
    final maxDeviceHeight485 = env['maxDeviceHeight485'] == true;
    final pointerCoarse = env['pointerCoarse'] == true;
    final hoverNone = env['hoverNone'] == true;
    final maxTouchPoints = (env['maxTouchPoints'] as num?)?.toInt() ?? 0;
    final userAgent = env['userAgent'] as String? ?? '';

    final causes = <String>[];
    if (innerWidth < _minDesktopWidth) {
      causes.add('innerWidth=$innerWidth (< $_minDesktopWidth)');
    }
    if (mobileMedia) {
      causes.add('matchMedia(max-width:768px)=true');
    }
    if (maxDeviceWidth485) {
      causes.add('matchMedia(max-device-width:485px)=true');
    }
    if (maxDeviceHeight485) {
      causes.add('matchMedia(max-device-height:485px)=true');
    }
    if (pointerCoarse) {
      causes.add('matchMedia(pointer:coarse)=true');
    }
    if (hoverNone) {
      causes.add('matchMedia(hover:none)=true');
    }
    if (maxTouchPoints > 0) {
      causes.add('maxTouchPoints=$maxTouchPoints');
    }
    if (userAgent.contains('Mobile') || userAgent.contains('iPhone')) {
      causes.add('mobile userAgent detected');
    }

    if (causes.isEmpty) {
      debugPrint('[checkout] desktop environment confirmed at $stage');
    } else {
      debugPrint(
        '[checkout] mobile layout risk at $stage: ${causes.join(', ')}',
      );
    }
  }

  void _maybeStartCheckout() {
    if (!_pageLoaded || !_layoutReady || _checkoutStarted || _completed) {
      return;
    }
    if (_controller == null) return;
    unawaited(_startCheckout());
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
      await _controller!.runJavaScript(
        'BillingBabaCheckout.start(${jsonEncode(config)});',
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
    final controller = _controller;
    if (controller == null) {
      return const ColoredBox(
        color: AppColors.surface,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasDesktopWidth = constraints.maxWidth >= _minDesktopWidth;
        if (hasDesktopWidth && !_layoutReady) {
          _layoutReady = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeStartCheckout();
          });
        }

        return ColoredBox(
          color: AppColors.surface,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: WebViewWidget(controller: controller),
          ),
        );
      },
    );
  }
}
