import 'dart:async';
import 'dart:convert';

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/domain/models/create_order_result.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/payment_bridge_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Result from the desktop Razorpay host, including the server order when known.
class SubscriptionPaymentHostResult {
  const SubscriptionPaymentHostResult({
    required this.payment,
    this.order,
    this.orderErrorMessage,
  });

  final CreateOrderResult? order;
  final PaymentBridgeResult payment;
  final String? orderErrorMessage;
}

/// Desktop Razorpay checkout hosted in [InAppWebView].
///
/// The dialog is shown immediately on user tap. [orderFuture] resolves while a
/// loading state is visible so Razorpay opens in an already-present host
/// (Razorpay requires checkout to open right after the user gesture).
Future<SubscriptionPaymentHostResult?> showRazorpayDesktopCheckout(
  BuildContext context, {
  required Future<CreateOrderResult?> orderFuture,
  required SubscriptionPlanType planType,
  required String? Function() orderErrorMessage,
}) async {
  final completer = Completer<SubscriptionPaymentHostResult?>();

  await showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierLabel: 'Razorpay Checkout',
    barrierColor: Colors.black54,
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _RazorpayDesktopCheckoutDialog(
        orderFuture: orderFuture,
        planType: planType,
        orderErrorMessage: orderErrorMessage,
        onResult: (result) {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        },
      );
    },
  );

  if (!completer.isCompleted) {
    completer.complete(null);
  }
  return completer.future;
}

Map<String, dynamic> razorpayCheckoutOptions({
  required CreateOrderResult order,
  required SubscriptionPlanType planType,
}) {
  return {
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
}

String _checkoutHtml(Map<String, dynamic> options) {
  final optionsJson = jsonEncode(options);
  return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Razorpay Checkout</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%; height: 100%; overflow: hidden; background: transparent;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    body { display: flex; align-items: center; justify-content: center; }
    #loading {
      display: flex; flex-direction: column; align-items: center;
      justify-content: center; gap: 16px; color: #666;
    }
    .spinner {
      width: 40px; height: 40px; border: 3px solid #f0f0f0;
      border-top-color: #528ff0; border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    .razorpay-container {
      position: fixed !important; inset: 0 !important;
      width: 100% !important; height: 100% !important; z-index: 999999 !important;
    }
  </style>
</head>
<body>
  <div id="loading"><div class="spinner"></div><div>Loading payment...</div></div>
  <script>
    (function forceDesktopEnvironment() {
      try {
        Object.defineProperty(navigator, 'maxTouchPoints', {
          get: function () { return 0; }, configurable: true
        });
      } catch (e) {}
      var originalMatchMedia = window.matchMedia.bind(window);
      window.matchMedia = function (query) {
        var q = String(query).toLowerCase();
        if (
          q.indexOf('max-device-width') !== -1 ||
          q.indexOf('max-device-height') !== -1 ||
          q.indexOf('pointer: coarse') !== -1 ||
          q.indexOf('hover: none') !== -1 ||
          q.indexOf('max-width: 485') !== -1 ||
          q.indexOf('max-width:485') !== -1
        ) {
          return {
            matches: false, media: query, onchange: null,
            addListener: function () {}, removeListener: function () {},
            addEventListener: function () {}, removeEventListener: function () {},
            dispatchEvent: function () { return false; }
          };
        }
        return originalMatchMedia(query);
      };
    })();

    var script = document.createElement('script');
    script.src = 'https://checkout.razorpay.com/v1/checkout.js';
    script.onload = function () { setTimeout(initPayment, 100); };
    script.onerror = function () {
      window.location.href = 'razorpay://error?code=SCRIPT_LOAD_ERROR&description=' +
        encodeURIComponent('Failed to load Razorpay');
    };
    document.head.appendChild(script);

    function initPayment() {
      try {
        if (typeof Razorpay === 'undefined') throw new Error('Razorpay not loaded');
        var options = $optionsJson;
        if (!options.modal) options.modal = {};
        options.modal.backdropclose = false;
        options.modal.escape = false;
        options.handler = function (response) {
          var params = 'razorpay_payment_id=' + encodeURIComponent(response.razorpay_payment_id || '');
          if (response.razorpay_order_id) {
            params += '&razorpay_order_id=' + encodeURIComponent(response.razorpay_order_id);
          }
          if (response.razorpay_signature) {
            params += '&razorpay_signature=' + encodeURIComponent(response.razorpay_signature);
          }
          window.location.href = 'razorpay://success?' + params;
        };
        options.modal.ondismiss = function () {
          window.location.href = 'razorpay://dismiss';
        };
        var rzp = new Razorpay(options);
        rzp.on('payment.failed', function (response) {
          var error = response.error || {};
          var params = 'code=' + encodeURIComponent(error.code || 'UNKNOWN_ERROR');
          params += '&description=' + encodeURIComponent(error.description || 'Payment failed');
          window.location.href = 'razorpay://error?' + params;
        });
        document.getElementById('loading').style.display = 'none';
        rzp.open();
      } catch (error) {
        window.location.href = 'razorpay://error?code=INIT_ERROR&description=' +
          encodeURIComponent(error.message);
      }
    }
  </script>
</body>
</html>
''';
}

/// Snap logical sizes to whole physical pixels to avoid macOS WKWebView frame
/// drift (AppKit fights Flutter over fractional platform-view widths).
double _snapToPhysical(double logical, double devicePixelRatio) {
  if (devicePixelRatio <= 0) return logical.floorToDouble();
  return (logical * devicePixelRatio).round() / devicePixelRatio;
}

class _RazorpayDesktopCheckoutDialog extends StatefulWidget {
  const _RazorpayDesktopCheckoutDialog({
    required this.orderFuture,
    required this.planType,
    required this.orderErrorMessage,
    required this.onResult,
  });

  final Future<CreateOrderResult?> orderFuture;
  final SubscriptionPlanType planType;
  final String? Function() orderErrorMessage;
  final ValueChanged<SubscriptionPaymentHostResult?> onResult;

  @override
  State<_RazorpayDesktopCheckoutDialog> createState() =>
      _RazorpayDesktopCheckoutDialogState();
}

class _RazorpayDesktopCheckoutDialogState
    extends State<_RazorpayDesktopCheckoutDialog> {
  CreateOrderResult? _order;
  var _isResolvingOrder = true;
  var _resultSent = false;

  /// Captured once so MediaQuery / window resize rebuilds do not recreate
  /// the WKWebView (which was thrashing memory and freezing checkout).
  late final double _dialogWidth;
  late final double _dialogHeight;
  late final Size _screenSizeAtOpen;
  var _sizesReady = false;

  String? _html;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveOrder());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sizesReady) return;

    final media = MediaQuery.of(context);
    final screenSize = media.size;
    final dpr = media.devicePixelRatio;
    _screenSizeAtOpen = screenSize;

    final rawWidth = screenSize.width > 800 ? 1000.0 : 440.0;
    final rawHeight = screenSize.width > 800 ? 580.0 : 680.0;
    _dialogWidth = _snapToPhysical(rawWidth, dpr);
    _dialogHeight = _snapToPhysical(rawHeight, dpr);
    _sizesReady = true;

    debugPrint(
      '[checkout] host ${_dialogWidth}x$_dialogHeight '
      '(window=${screenSize.width.toStringAsFixed(0)}x'
      '${screenSize.height.toStringAsFixed(0)}, dpr=$dpr)',
    );
  }

  Future<void> _resolveOrder() async {
    try {
      final order = await widget.orderFuture;
      if (!mounted) return;

      if (order == null) {
        final message =
            widget.orderErrorMessage() ??
            'Unable to create payment order. Please try again.';
        _emitResult(
          SubscriptionPaymentHostResult(
            payment: PaymentBridgeFailed(message),
            orderErrorMessage: message,
          ),
        );
        return;
      }

      final options = razorpayCheckoutOptions(
        order: order,
        planType: widget.planType,
      );
      setState(() {
        _order = order;
        _html = _checkoutHtml(options);
        _isResolvingOrder = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      final message = error.toString();
      _emitResult(
        SubscriptionPaymentHostResult(
          payment: PaymentBridgeFailed(message),
          orderErrorMessage: message,
        ),
      );
    }
  }

  void _emitResult(SubscriptionPaymentHostResult? result) {
    if (_resultSent) return;
    _resultSent = true;
    widget.onResult(result);
  }

  String _desktopUserAgent() {
    if (AppPlatform.current.isMacOS) {
      return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/120.0.0.0 Safari/537.36';
    }
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Safari/537.36';
  }

  void _handleCustomSchemeUrl(String url) {
    final order = _order;
    if (order == null) return;

    final uri = Uri.parse(url);
    late final PaymentBridgeResult payment;
    switch (uri.host) {
      case 'success':
        final paymentId = uri.queryParameters['razorpay_payment_id'] ?? '';
        final orderId = uri.queryParameters['razorpay_order_id'] ?? '';
        final signature = uri.queryParameters['razorpay_signature'] ?? '';
        if (paymentId.isEmpty || orderId.isEmpty || signature.isEmpty) {
          payment = const PaymentBridgeFailed(
            'Incomplete payment response from Razorpay.',
          );
        } else {
          payment = PaymentBridgeSuccess(
            razorpayPaymentId: paymentId,
            razorpayOrderId: orderId,
            razorpaySignature: signature,
          );
        }
      case 'error':
        payment = PaymentBridgeFailed(
          uri.queryParameters['description'] ?? 'Payment failed.',
        );
      case 'dismiss':
        payment = const PaymentBridgeCancelled();
      default:
        return;
    }

    _emitResult(SubscriptionPaymentHostResult(order: order, payment: payment));
  }

  InAppWebViewSettings _webViewSettings() {
    return InAppWebViewSettings(
      javaScriptEnabled: true,
      domStorageEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,
      supportMultipleWindows: true,
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      transparentBackground: true,
      userAgent: _desktopUserAgent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_sizesReady) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: _dialogWidth,
          height: _dialogHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: AppColors.surface,
              child: _isResolvingOrder
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCheckoutWebView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutWebView() {
    final order = _order;
    final html = _html;
    if (order == null || html == null) {
      return const SizedBox.shrink();
    }

    return InAppWebView(
      key: ValueKey(order.paymentUuid),
      initialData: InAppWebViewInitialData(
        data: html,
        encoding: 'utf-8',
        baseUrl: WebUri('https://checkout.razorpay.com'),
      ),
      initialSettings: _webViewSettings(),
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url.toString();
        if (url.startsWith('razorpay://')) {
          _handleCustomSchemeUrl(url);
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onConsoleMessage: (controller, message) {
        debugPrint('[checkout] console: ${message.message}');
      },
      onCreateWindow: (controller, createWindowAction) async {
        if (!context.mounted) return true;
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final popupWidth = _snapToPhysical(
          _screenSizeAtOpen.width > 900
              ? 900.0
              : _screenSizeAtOpen.width - 32,
          dpr,
        );
        final popupHeight = _snapToPhysical(
          _screenSizeAtOpen.height > 750
              ? 700.0
              : _screenSizeAtOpen.height - 80,
          dpr,
        );

        unawaited(
          showDialog<void>(
            context: context,
            useRootNavigator: true,
            barrierDismissible: false,
            builder: (popupContext) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth: popupWidth,
                  maxHeight: popupHeight,
                ),
                child: SizedBox(
                  width: popupWidth,
                  height: popupHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: InAppWebView(
                        windowId: createWindowAction.windowId,
                        initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          domStorageEnabled: true,
                          useShouldOverrideUrlLoading: true,
                          transparentBackground: true,
                        ),
                        onCloseWindow: (_) {
                          Navigator.of(popupContext).pop();
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        return true;
      },
    );
  }
}
