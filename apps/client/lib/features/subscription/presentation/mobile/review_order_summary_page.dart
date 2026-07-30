import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/features/subscription/application/payment_state_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_order_pricing.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/utils/subscription_price_format.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/widgets/coupon_input_section.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/widgets/expandable_gstin_field.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/widgets/order_price_breakdown.dart';
import 'package:billing_baba/features/subscription/presentation/mobile/widgets/selected_plan_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReviewOrderSummaryPage extends ConsumerStatefulWidget {
  const ReviewOrderSummaryPage({super.key});

  @override
  ConsumerState<ReviewOrderSummaryPage> createState() =>
      _ReviewOrderSummaryPageState();
}

class _ReviewOrderSummaryPageState extends ConsumerState<ReviewOrderSummaryPage> {
  var _isPaying = false;

  Future<void> _handlePay(double total) async {
    if (_isPaying) return;
    setState(() => _isPaying = true);

    ref.read(paymentStateProvider.notifier).reset();
    if (!mounted) return;
    await context.push(AppRoutes.subscriptionPaymentProcessing);
    if (mounted) setState(() => _isPaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(subscriptionCheckoutSessionProvider);
    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const MobileAppBar(
          title: 'Review Order',
          showBackButton: true,
          showBusinessHeader: false,
          showNotification: false,
          showSettings: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Checkout session expired.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.plansPricing),
                  child: const Text('Back to Plans'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pricing = SubscriptionOrderPricing.calculate(
      input: session.input,
      couponDiscountOnTaxable: session.couponDiscountOnTaxable,
    );
    final paymentState = ref.watch(paymentStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Review Order Summary',
        showBackButton: true,
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                SelectedPlanSummaryCard(input: session.input),
                const SizedBox(height: AppSpacing.md),
                OrderPriceBreakdown(pricing: pricing),
                const SizedBox(height: AppSpacing.md),
                CouponInputSection(
                  appliedCouponCode: session.appliedCouponCode,
                  onApply: (code) async {
                    return ref
                        .read(subscriptionCheckoutSessionProvider.notifier)
                        .applyCoupon(code);
                  },
                  onRemove: () => ref
                      .read(subscriptionCheckoutSessionProvider.notifier)
                      .removeCoupon(),
                ),
                const SizedBox(height: AppSpacing.md),
                ExpandableGstinField(
                  initialValue: session.gstin,
                  onChanged: (value) => ref
                      .read(subscriptionCheckoutSessionProvider.notifier)
                      .updateGstin(value),
                ),
              ],
            ),
          ),
          _StickyPayCta(
            total: pricing.total,
            isLoading: _isPaying || paymentState.isLoading,
            onPressed: () => _handlePay(pricing.total),
          ),
        ],
      ),
    );
  }
}

class _StickyPayCta extends StatelessWidget {
  const _StickyPayCta({
    required this.total,
    required this.isLoading,
    required this.onPressed,
  });

  final double total;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdBorder,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Pay ${formatSubscriptionPrice(total)} Now',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
