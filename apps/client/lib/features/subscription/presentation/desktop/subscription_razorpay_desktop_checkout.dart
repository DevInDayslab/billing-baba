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
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _RazorpayDesktopCheckoutDialog(
        options: options,
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

class _RazorpayDesktopCheckoutDialog extends StatelessWidget {
  const _RazorpayDesktopCheckoutDialog({
    required this.options,
    required this.onResult,
  });

  final Map<String, dynamic> options;
  final ValueChanged<PaymentBridgeResult> onResult;

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
    final uri = Uri.parse(url);
    switch (uri.host) {
      case 'success':
        final paymentId = uri.queryParameters['razorpay_payment_id'] ?? '';
        final orderId = uri.queryParameters['razorpay_order_id'] ?? '';
        final signature = uri.queryParameters['razorpay_signature'] ?? '';
        if (paymentId.isEmpty || orderId.isEmpty || signature.isEmpty) {
          onResult(
            const PaymentBridgeFailed(
              'Incomplete payment response from Razorpay.',
            ),
          );
          return;
        }
        onResult(
          PaymentBridgeSuccess(
            razorpayPaymentId: paymentId,
            razorpayOrderId: orderId,
            razorpaySignature: signature,
          ),
        );
      case 'error':
        onResult(
          PaymentBridgeFailed(
            uri.queryParameters['description'] ?? 'Payment failed.',
          ),
        );
      case 'dismiss':
        onResult(const PaymentBridgeCancelled());
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    // width ≤ 800 → compact; width > 800 → desktop
    final double dialogWidth;
    final double dialogHeight;
    if (screenSize.width > 800) {
      dialogWidth = 1000;
      dialogHeight = 580;
    } else {
      dialogWidth = 440;
      dialogHeight = 680;
    }

    debugPrint(
      '[checkout] host ${dialogWidth.toInt()}x${dialogHeight.toInt()} '
      '(window=${screenSize.width.toStringAsFixed(0)}x'
      '${screenSize.height.toStringAsFixed(0)})',
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _checkoutHtml(options),
                encoding: 'utf-8',
                baseUrl: WebUri('https://checkout.razorpay.com'),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptCanOpenWindowsAutomatically: true,
                supportMultipleWindows: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                transparentBackground: true,
                userAgent: _desktopUserAgent(),
              ),
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
                // Netbanking / bank redirects open in a popup WebView.
                if (!context.mounted) return true;
                final popupWidth =
                    screenSize.width > 900 ? 900.0 : screenSize.width - 32;
                final popupHeight =
                    screenSize.height > 750 ? 700.0 : screenSize.height - 80;

                unawaited(
                  showDialog<void>(
                    context: context,
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
            ),
          ),
        ),
      ),
    );
  }
}
