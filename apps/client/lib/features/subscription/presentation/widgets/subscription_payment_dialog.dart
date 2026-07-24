import 'dart:async';
import 'dart:developer' as developer;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_helper.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/desktop_payment_webview.dart';
import 'package:billing_baba/features/subscription/presentation/widgets/subscription_payment_host_audit.dart';
import 'package:billing_baba/features/subscription/providers/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SubscriptionPaymentResult {
  activated,
  cancelled,
  dismissed,
}

enum PaymentDialogStatus {
  checkout,
  verifying,
  success,
  failed,
  timedOut,
}

/// Shows a borderless desktop payment overlay. Returns how the flow ended.
Future<SubscriptionPaymentResult> showSubscriptionPaymentDialog(
  BuildContext context, {
  required CreateOrderResponseModel order,
  required SubscriptionPlanCode expectedPlan,
  required String planName,
}) async {
  final result = await Navigator.of(context, rootNavigator: true)
      .push<SubscriptionPaymentResult>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SubscriptionPaymentOverlay(
          order: order,
          expectedPlan: expectedPlan,
          planName: planName,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
  return result ?? SubscriptionPaymentResult.dismissed;
}

class SubscriptionPaymentOverlay extends ConsumerStatefulWidget {
  const SubscriptionPaymentOverlay({
    required this.order,
    required this.expectedPlan,
    required this.planName,
    super.key,
  });

  final CreateOrderResponseModel order;
  final SubscriptionPlanCode expectedPlan;
  final String planName;

  @override
  ConsumerState<SubscriptionPaymentOverlay> createState() =>
      _SubscriptionPaymentOverlayState();
}

class _SubscriptionPaymentOverlayState
    extends ConsumerState<SubscriptionPaymentOverlay> {
  static const _timeout = Duration(minutes: 3);
  static const _sheetCornerRadius = 12.0;
  static const _barrierColor = Color(0x9E000000);

  final GlobalKey _webViewHostKey = GlobalKey();
  var _hostAuditLogged = false;

  PaymentDialogStatus _status = PaymentDialogStatus.checkout;
  String? _statusMessage;
  var _retryCount = 0;
  late final DateTime _deadline;
  late final PaymentCheckoutConfig _checkoutConfig;
  late final bool _profileReady;

  @override
  void initState() {
    super.initState();
    _deadline = DateTime.now().add(_timeout);
    _checkoutConfig = buildCheckoutConfig(
      order: widget.order,
      planName: widget.planName,
    );
    _profileReady = isSubscriptionOrderCheckoutReady(widget.order);

    if (!_profileReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(subscriptionProfileIncompleteMessage)),
        );
        _closeWithResult(SubscriptionPaymentResult.dismissed);
      });
    }
  }

  void _closeWithResult(SubscriptionPaymentResult result) {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(result);
  }

  void _scheduleHostAudit() {
    if (_hostAuditLogged) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hostAuditLogged) {
        return;
      }
      _hostAuditLogged = true;
      auditSubscriptionPaymentHostTree(
        overlayContext: context,
        webViewContext: _webViewHostKey.currentContext,
      );
    });
  }

  void _handleBridgeMessage(Map<String, dynamic> message) {
    if (_status == PaymentDialogStatus.success ||
        _status == PaymentDialogStatus.verifying) {
      return;
    }

    if (DateTime.now().isAfter(_deadline)) {
      setState(() {
        _status = PaymentDialogStatus.timedOut;
        _statusMessage = 'Payment timed out. Please try again.';
      });
      return;
    }

    final event = message['event'] as String? ?? '';
    switch (event) {
      case 'checkout_viewport':
        developer.log(
          'innerWidth=${message['innerWidth']}, '
          'innerHeight=${message['innerHeight']}, '
          'userAgent=${message['userAgent']}',
          name: 'subscription.checkout',
        );
      case 'payment_started':
        setState(() {
          _status = PaymentDialogStatus.checkout;
          _statusMessage = null;
        });
      case 'payment_success':
        unawaited(_verifyPayment(message));
      case 'payment_failed':
        setState(() {
          _status = PaymentDialogStatus.failed;
          _statusMessage =
              message['message'] as String? ?? 'Payment failed. Please try again.';
        });
      case 'payment_cancelled':
        _closeWithResult(SubscriptionPaymentResult.cancelled);
    }
  }

  Future<void> _verifyPayment(Map<String, dynamic> message) async {
    setState(() {
      _status = PaymentDialogStatus.verifying;
      _statusMessage = 'Verifying payment...';
    });

    try {
      final repository = await ref.read(subscriptionRepositoryProvider.future);
      await repository.verifyPayment(
        paymentUuid: widget.order.paymentUuid,
        razorpayOrderId:
            message['razorpayOrderId'] as String? ?? widget.order.razorpayOrderId,
        razorpayPaymentId: message['razorpayPaymentId'] as String? ?? '',
        razorpaySignature: message['razorpaySignature'] as String? ?? '',
      );

      if (!mounted) return;
      setState(() => _status = PaymentDialogStatus.success);
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        _closeWithResult(SubscriptionPaymentResult.activated);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = PaymentDialogStatus.failed;
        _statusMessage = error.toString();
      });
    }
  }

  void _retryCheckout() {
    setState(() {
      _retryCount++;
      _status = PaymentDialogStatus.checkout;
      _statusMessage = null;
      _hostAuditLogged = false;
    });
  }

  Widget _buildPaymentWebView() {
    return KeyedSubtree(
      key: _webViewHostKey,
      child: buildDesktopPaymentWebView(
        key: ValueKey('${widget.order.paymentUuid}-$_retryCount'),
        config: _checkoutConfig,
        onMessage: _handleBridgeMessage,
      ),
    );
  }

  Widget _buildSheetContent() {
    const probeColor = kSubscriptionPaymentHostProbeColor;
    final webView = _buildPaymentWebView();

    if (_status == PaymentDialogStatus.checkout && probeColor == null) {
      return webView;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (probeColor != null)
          ColoredBox(color: probeColor, child: const SizedBox.expand()),
        webView,
        if (_status == PaymentDialogStatus.verifying)
          _PaymentInlineStatus(
            showProgress: true,
            message: _statusMessage ?? 'Verifying payment...',
          ),
        if (_status == PaymentDialogStatus.failed ||
            _status == PaymentDialogStatus.timedOut)
          _PaymentInlineStatus(
            message: _statusMessage ?? 'Payment could not be completed.',
            actions: [
              if (_status == PaymentDialogStatus.failed ||
                  _status == PaymentDialogStatus.timedOut)
                FilledButton(
                  onPressed: _retryCheckout,
                  child: const Text('Retry'),
                ),
              OutlinedButton(
                onPressed: () =>
                    _closeWithResult(SubscriptionPaymentResult.dismissed),
                child: const Text('Close'),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _scheduleHostAudit();

    const routeAnimation = AlwaysStoppedAnimation<double>(1);

    if (!_profileReady) {
      return const Stack(
        fit: StackFit.expand,
        children: [
          AnimatedModalBarrier(
            dismissible: false,
            color: AlwaysStoppedAnimation<Color?>(_barrierColor),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const AnimatedModalBarrier(
          dismissible: false,
          color: AlwaysStoppedAnimation<Color?>(_barrierColor),
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_sheetCornerRadius),
            child: _buildSheetContent(),
          ),
        ),
      ],
    );
  }
}

class _PaymentInlineStatus extends StatelessWidget {
  const _PaymentInlineStatus({
    required this.message,
    this.showProgress = false,
    this.actions = const [],
  });

  final bool showProgress;
  final String message;
  final List<Widget> actions;

  static const _labelShadow = [
    Shadow(blurRadius: 10, color: Color(0xE6000000)),
    Shadow(blurRadius: 4, color: Color(0xCC000000)),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showProgress) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
              shadows: _labelShadow,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}
