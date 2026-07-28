import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/application/mobile_feature_comparison_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _animationDuration = Duration(milliseconds: 250);

/// Vyapar-style expandable plan card for mobile Plans & Pricing.
class MobilePlanCard extends StatelessWidget {
  const MobilePlanCard({
    required this.plan,
    required this.pricing,
    required this.features,
    required this.isGold,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.onViewAllFeatures,
    this.featurePreviewLimit = 8,
  });

  final PricingPlan plan;
  final PlanPricing pricing;
  final List<PlanFeature> features;
  final bool isGold;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onViewAllFeatures;
  final int featurePreviewLimit;

  static const _selectedBorderColor = Color(0xFFE91E63);
  static const _selectedBackground = Color(0xFFFFF8FB);
  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);
  static const _platinumIconBg = Color(0xFFEDE7F6);
  static const _platinumIconColor = Color(0xFF5E35B1);
  static const _checkBadgeColor = Color(0xFF43A047);
  static const _checkColor = Color(0xFF2E7D32);
  static const _crossColor = Color(0xFFD32F2F);

  static final _priceFormat = NumberFormat('#,##0.##', 'en_IN');

  String _formatPrice(double price) => '₹${_priceFormat.format(price)}';

  List<PlanFeature> get _visibleFeatures => features
      .where((feature) => !feature.isCategoryHeader)
      .take(featurePreviewLimit)
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? _selectedBackground : AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(
          color: isSelected ? _selectedBorderColor : const Color(0xFFE0E0E0),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: _selectedBorderColor.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgBorder,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanHeader(
                      plan: plan,
                      pricing: pricing,
                      isGold: isGold,
                      isSelected: isSelected,
                      formatPrice: _formatPrice,
                    ),
                    AnimatedSize(
                      duration: _animationDuration,
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: isSelected
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: AppSpacing.md),
                                const Divider(height: 1),
                                const SizedBox(height: AppSpacing.md),
                                ..._visibleFeatures.map(
                                  (feature) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.sm,
                                    ),
                                    child: _FeatureListItem(
                                      feature: feature,
                                      isGold: isGold,
                                    ),
                                  ),
                                ),
                                if (onViewAllFeatures != null)
                                  TextButton.icon(
                                    onPressed: onViewAllFeatures,
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('View All Features'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.sm,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                ),
              if (plan.isMostPopular)
                Positioned(
                  top: -8,
                  left: AppSpacing.lg,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: AppRadius.smBorder,
                    ),
                    child: Text(
                      'Most Popular',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.plan,
    required this.pricing,
    required this.isGold,
    required this.isSelected,
    required this.formatPrice,
  });

  final PricingPlan plan;
  final PlanPricing pricing;
  final bool isGold;
  final bool isSelected;
  final String Function(double) formatPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isGold
                ? MobilePlanCard._goldIconBg
                : MobilePlanCard._platinumIconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isGold ? Icons.change_history : Icons.flag_outlined,
            color: isGold
                ? MobilePlanCard._goldIconColor
                : MobilePlanCard._platinumIconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.mobileDisplayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (isSelected) ...[
                    Text(
                      formatPrice(pricing.originalPrice),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    formatPrice(pricing.discountedPrice),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Only ${formatPrice(pricing.perMonthPrice)} per month',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _SelectionIndicator(isSelected: isSelected),
      ],
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animationDuration,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? MobilePlanCard._checkBadgeColor : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? MobilePlanCard._checkBadgeColor
              : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  const _FeatureListItem({
    required this.feature,
    required this.isGold,
  });

  final PlanFeature feature;
  final bool isGold;

  @override
  Widget build(BuildContext context) {
    final value = isGold ? feature.goldValue : feature.platinumValue;

    Widget trailing;
    if (value != null) {
      trailing = Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      );
    } else {
      final included = isGold ? feature.goldIncluded : feature.platinumIncluded;
      trailing = Icon(
        included == true ? Icons.check : Icons.close,
        color: included == true
            ? MobilePlanCard._checkColor
            : MobilePlanCard._crossColor,
        size: 20,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            feature.name,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
        trailing,
      ],
    );
  }
}
