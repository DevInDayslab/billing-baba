import 'dart:async';
import 'dart:convert';

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/payment_bridge_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Desktop Razorpay checkout hosted in [InAppWebView].
///
/// Mirrors `razorpay_web`'s desktop path (HTML checkout + netbanking popups)
/// but sizes the host ourselves. Upstream `razorpay_web` hardcodes 480px and
/// always shows Razorpay's mobile layout.
Future<PaymentBridgeResult> showRazorpayDesktopCheckout(
  BuildContext context, {
  required Map<String, dynamic> options,
}) async {
  final completer = Completer<PaymentBridgeResult>();

  await showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Razorpay Checkout',
    barrierColor: Colors.black54,
    transitionDuration: Duration.zero,
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _RazorpayDesktopCheckoutDialog(
        options: options,
        onResult: (result) {
          if (!completer.isCompleted) {
            completer.complete(result);
          }
          if (dialogContext.mounted &&
              Navigator.of(dialogContext, rootNavigator: true).canPop()) {
            Navigator.of(dialogContext, rootNavigator: true).pop();
          }
        },
      );
    },
  );

  if (!completer.isCompleted) {
    completer.complete(const PaymentBridgeCancelled());
  }
  return completer.future;
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
      width: 100%; height: 100%; overflow: hidden; background: #fff;
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
    required this.options,
    required this.onResult,
  });

  final Map<String, dynamic> options;
  final ValueChanged<PaymentBridgeResult> onResult;

  @override
  State<_RazorpayDesktopCheckoutDialog> createState() =>
      _RazorpayDesktopCheckoutDialogState();
}

class _RazorpayDesktopCheckoutDialogState
    extends State<_RazorpayDesktopCheckoutDialog> {
  /// Captured once so MediaQuery / window resize rebuilds do not recreate
  /// the WKWebView (which was thrashing memory and freezing checkout).
  late final double _dialogWidth;
  late final double _dialogHeight;
  late final String _html;
  late final String _userAgent;
  late final Size _screenSizeAtOpen;

  var _sizesReady = false;
  var _resultSent = false;

  static String _desktopUserAgent() {
    if (AppPlatform.current.isMacOS) {
      return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/120.0.0.0 Safari/537.36';
    }
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Safari/537.36';
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
    _html = _checkoutHtml(widget.options);
    _userAgent = _desktopUserAgent();
    _sizesReady = true;

    debugPrint(
      '[checkout] host ${_dialogWidth}x$_dialogHeight '
      '(window=${screenSize.width.toStringAsFixed(0)}x'
      '${screenSize.height.toStringAsFixed(0)}, dpr=$dpr)',
    );
  }

  void _emitResult(PaymentBridgeResult result) {
    if (_resultSent) return;
    _resultSent = true;
    // Drop the WKWebView immediately so Razorpay's post-success blank page
    // never shows as a white rectangle while we close the dialog.
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onResult(result);
    });
  }

  void _handleCustomSchemeUrl(String url) {
    final uri = Uri.parse(url);
    switch (uri.host) {
      case 'success':
        final paymentId = uri.queryParameters['razorpay_payment_id'] ?? '';
        final orderId = uri.queryParameters['razorpay_order_id'] ?? '';
        final signature = uri.queryParameters['razorpay_signature'] ?? '';
        if (paymentId.isEmpty || orderId.isEmpty || signature.isEmpty) {
          _emitResult(
            const PaymentBridgeFailed(
              'Incomplete payment response from Razorpay.',
            ),
          );
          return;
        }
        _emitResult(
          PaymentBridgeSuccess(
            razorpayPaymentId: paymentId,
            razorpayOrderId: orderId,
            razorpaySignature: signature,
          ),
        );
      case 'error':
        _emitResult(
          PaymentBridgeFailed(
            uri.queryParameters['description'] ?? 'Payment failed.',
          ),
        );
      case 'dismiss':
        _emitResult(const PaymentBridgeCancelled());
      default:
        break;
    }
  }

  Widget _checkoutShell({required Widget child}) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Material(
          color: Colors.white,
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: _dialogWidth,
            height: _dialogHeight,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_sizesReady) {
      return const SizedBox.shrink();
    }

    if (_resultSent) {
      return _checkoutShell(
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Confirming payment…'),
            ],
          ),
        ),
      );
    }

    // Opaque Material (not ClipRRect) — clipping platform views on macOS
    // contributes to WKWebView frame drift / UI freezes.
    return _checkoutShell(
      child: InAppWebView(
        key: const ValueKey('razorpay-desktop-checkout'),
        initialData: InAppWebViewInitialData(
          data: _html,
          encoding: 'utf-8',
          baseUrl: WebUri('https://checkout.razorpay.com'),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptCanOpenWindowsAutomatically: true,
          supportMultipleWindows: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          userAgent: _userAgent,
          cacheEnabled: false,
          disableHorizontalScroll: true,
          disableVerticalScroll: true,
        ),
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url.toString();
          if (url.startsWith('razorpay://')) {
            _handleCustomSchemeUrl(url);
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
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
              barrierDismissible: false,
              builder: (popupContext) {
                return Dialog(
                  backgroundColor: Colors.white,
                  insetPadding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: popupWidth,
                    maxHeight: popupHeight,
                  ),
                  child: SizedBox(
                    width: popupWidth,
                    height: popupHeight,
                    child: InAppWebView(
                      windowId: createWindowAction.windowId,
                      initialSettings: InAppWebViewSettings(
                        cacheEnabled: false,
                      ),
                      onCloseWindow: (_) {
                        if (Navigator.of(popupContext).canPop()) {
                          Navigator.of(popupContext).pop();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
          return true;
        },
      ),
    );
  }
}
