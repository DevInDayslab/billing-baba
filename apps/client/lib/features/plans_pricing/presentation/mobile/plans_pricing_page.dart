import 'dart:async';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/application/mobile_feature_comparison_data.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/application/mobile_plans_selection_provider.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/widgets/mobile_feature_comparison_sheet.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/widgets/mobile_plan_card.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/widgets/mobile_plans_pricing_more_options_sheet.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_mapper.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_view_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session.dart';
import 'package:billing_baba/features/subscription/application/subscription_checkout_session_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_error_mapper.dart';
import 'package:billing_baba/features/subscription/application/subscription_plan_type_resolver.dart';
import 'package:billing_baba/features/subscription/domain/subscription_plan_metadata.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/review_order_summary_input.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vyapar-style mobile Plans & Pricing screen with accordion plan cards.
class MobilePlansPricingPage extends ConsumerWidget {
  const MobilePlansPricingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(plansPricingViewProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: 'Plans & Pricing',
        showBackButton: true,
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
        actions: [
          IconButton(
            tooltip: 'More options',
            icon: const Icon(LucideIcons.ellipsisVertical),
            onPressed: () =>
                showMobilePlansPricingMoreOptionsSheet(context, ref),
          ),
        ],
      ),
      body: viewAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  SubscriptionErrorMapper.messageFor(error),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.read(plansPricingViewProvider.notifier).reload(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (viewData) => _PlansPricingBody(viewData: viewData),
      ),
    );
  }
}

class _PlansPricingBody extends ConsumerWidget {
  const _PlansPricingBody({required this.viewData});

  final PlansPricingViewData viewData;

  PricingPlanType _planTypeFor(PricingPlan plan) =>
      plan.isGold ? PricingPlanType.gold : PricingPlanType.platinum;

  void _openReviewOrder(
    BuildContext context,
    WidgetRef ref,
    PricingPlan plan,
    PlanPlatform platform,
    PlanDuration duration,
  ) {
    final planType = subscriptionPlanTypeFor(plan);
    final pricing = plan.pricingFor(platform, duration);
    final metadata = metadataFor(planType);

    ref
        .read(subscriptionCheckoutSessionProvider.notifier)
        .startSession(
          SubscriptionCheckoutSession(
            input: ReviewOrderSummaryInput(
              planType: planType,
              planName: plan.mobileDisplayName,
              platform: platform,
              duration: duration,
              discountedPrice: pricing.discountedPrice,
              originalPrice: pricing.originalPrice,
              licenseType: metadata.licenseType,
              deviceLimit: metadata.deviceLimit,
              durationLabel: duration.label,
            ),
          ),
        );

    unawaited(context.push(AppRoutes.subscriptionReview));
  }

  void _showAllFeaturesSheet(BuildContext context, WidgetRef ref) {
    unawaited(
      showMobileFeatureComparisonSheet(
        context: context,
        ref: ref,
        viewData: viewData,
        onPurchase: (plan) async {
          _openReviewOrder(
            context,
            ref,
            plan,
            ref.read(mobilePlansSelectionProvider).platform,
            ref.read(mobilePlansSelectionProvider).duration,
          );
        },
      ),
    );
  }

  String _ctaLabel(
    PricingPlan plan,
    PlanPlatform platform,
    PlanDuration duration,
  ) {
    final pricing = plan.pricingFor(platform, duration);
    final tierLabel = _planTypeFor(plan).comparisonTierLabel;
    if (pricing.ctaLabel.startsWith('Renew ')) {
      return 'Renew $tierLabel';
    }
    if (pricing.ctaLabel.startsWith('Upgrade ')) {
      return 'Upgrade to $tierLabel';
    }
    if (pricing.ctaLabel.startsWith('Get ')) {
      return 'Get $tierLabel';
    }
    return 'Get $tierLabel';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(mobilePlansSelectionProvider);
    final plans = viewData.plans;
    final selectedPlan = plans.firstWhere(
      (plan) => _planTypeFor(plan) == selection.selectedPlan,
      orElse: () => plans.first,
    );
    final selectedPricing = selectedPlan.pricingFor(
      selection.platform,
      selection.duration,
    );
    final priceFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final ctaLabel = _ctaLabel(
      selectedPlan,
      selection.platform,
      selection.duration,
    );

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(plansPricingViewProvider.notifier).reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                _DurationSelector(
                  selected: selection.duration,
                  onChanged: ref
                      .read(mobilePlansSelectionProvider.notifier)
                      .setDuration,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final plan in plans) ...[
                  MobilePlanCard(
                    plan: plan,
                    pricing: plan.pricingFor(
                      selection.platform,
                      selection.duration,
                    ),
                    features:
                        plan.featuresByPlatform[selection.platform] ?? const [],
                    isGold: plan.isGold,
                    isSelected: _planTypeFor(plan) == selection.selectedPlan,
                    onTap: () => ref
                        .read(mobilePlansSelectionProvider.notifier)
                        .selectPlan(_planTypeFor(plan)),
                    onViewAllFeatures:
                        _planTypeFor(plan) == selection.selectedPlan
                        ? () => _showAllFeaturesSheet(context, ref)
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
        _StickyPlanCta(
          label: ctaLabel,
          subtitle:
              '${selectedPlan.mobileDisplayName} · ${selection.duration.label} · ${priceFormat.format(selectedPricing.discountedPrice)}',
          onPressed: () => _openReviewOrder(
            context,
            ref,
            selectedPlan,
            selection.platform,
            selection.duration,
          ),
        ),
      ],
    );
  }
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.selected,
    required this.onChanged,
  });

  final PlanDuration selected;
  final ValueChanged<PlanDuration> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final duration in PlanDuration.values) ...[
          Expanded(
            child: _DurationChip(
              label: duration.label,
              isSelected: selected == duration,
              onTap: () => onChanged(duration),
            ),
          ),
          if (duration != PlanDuration.values.last)
            const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF8FB) : AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(
          color: isSelected ? const Color(0xFFE91E63) : const Color(0xFFE0E0E0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFE91E63)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyPlanCta extends StatelessWidget {
  const _StickyPlanCta({
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
