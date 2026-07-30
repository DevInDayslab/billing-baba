import 'dart:async';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/subscription/application/mock_payment_service.dart';
import 'package:billing_baba/features/subscription/application/payment_state_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session_provider.dart';
import 'package:billing_baba/features/subscription/domain/models/payment_outcome.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/widgets/payment_failed_dialog.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/widgets/payment_pending_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Cashfree-style payment processing screen with mock status polling.
class PaymentProcessingPage extends ConsumerStatefulWidget {
  const PaymentProcessingPage({super.key});

  @override
  ConsumerState<PaymentProcessingPage> createState() =>
      _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends ConsumerState<PaymentProcessingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  var _hasStarted = false;
  var _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startPayment());
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    if (_hasStarted) return;
    _hasStarted = true;

    final result = await ref
        .read(paymentStateProvider.notifier)
        .processPayment();
    if (!mounted) return;

    if (result == null) {
      final paymentState = ref.read(paymentStateProvider);
      if (paymentState.status == PaymentStatus.failed) {
        await _showFailedDialog();
      }
      return;
    }

    await _handleOutcome(result.outcome);
  }

  Future<void> _showFailedDialog() async {
    if (_dialogShown) return;
    _dialogShown = true;
    if (!mounted) return;
    await showPaymentFailedDialog(
      context,
      ref: ref,
      onRetryPayment: _retryPayment,
      onChangePlan: _changePlan,
      onCancel: _goHome,
    );
  }

  Future<void> _handleOutcome(PaymentOutcome outcome) async {
    if (_dialogShown) return;

    switch (outcome) {
      case PaymentOutcome.success:
        if (!mounted) return;
        context.go(AppRoutes.subscriptionPaymentSuccess);
      case PaymentOutcome.pending:
        _dialogShown = true;
        if (!mounted) return;
        await showPaymentPendingDialog(
          context,
          ref: ref,
          onRetryStatus: _retryStatus,
          onHome: _goHome,
        );
      case PaymentOutcome.failed:
        await _showFailedDialog();
    }
  }

  Future<void> _retryStatus() async {
    _dialogShown = false;
    final result = await ref
        .read(paymentStateProvider.notifier)
        .retryStatusCheck();
    if (!mounted || result == null) return;
    await _handleOutcome(result.outcome);
  }

  void _retryPayment() {
    _dialogShown = false;
    ref.read(paymentStateProvider.notifier).reset();
    if (!mounted) return;
    context.go(AppRoutes.subscriptionReview);
  }

  void _changePlan() {
    _dialogShown = false;
    ref.read(subscriptionCheckoutSessionProvider.notifier).clearSession();
    ref.read(paymentStateProvider.notifier).reset();
    if (!mounted) return;
    context.go(AppRoutes.plansPricing);
  }

  void _goHome() {
    ref.read(subscriptionCheckoutSessionProvider.notifier).clearSession();
    ref.read(paymentStateProvider.notifier).reset();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  Future<bool> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel payment?'),
        content: const Text(
          'Your payment is still processing. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _handleBack() async {
    final paymentState = ref.read(paymentStateProvider);
    if (paymentState.isLoading) {
      final confirmed = await _confirmCancel();
      if (!confirmed || !mounted) return;
    }
    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentStateProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: const Text(
            'Processing Payment',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Checking payment status...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Please do not close the app or press back.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (paymentState.isLoading)
                  const CircularProgressIndicator()
                else
                  const SizedBox(height: 24),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Powered by secure payment gateway',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Need help? Call ${MockPaymentService.supportPhoneNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
