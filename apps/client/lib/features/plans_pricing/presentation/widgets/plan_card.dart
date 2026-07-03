import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.plan,
    required this.pricing,
    required this.features,
    required this.isGold,
    this.compact = false,
    this.overviewFeatureLimit = 10,
    this.featuresExpanded = false,
    this.onToggleFeatures,
    this.onCtaPressed,
    super.key,
  });

  final PricingPlan plan;
  final PlanPricing pricing;
  final List<PlanFeature> features;
  final bool isGold;
  final bool compact;
  final int overviewFeatureLimit;
  final bool featuresExpanded;
  final VoidCallback? onToggleFeatures;
  final VoidCallback? onCtaPressed;
  static const _platinumBg = Color(0xFFF3F0FF);
  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);
  static const _platinumIconBg = Color(0xFFEDE7F6);
  static const _platinumIconColor = Color(0xFF5E35B1);
  static const _checkColor = Color(0xFF2E7D32);
  static const _crossColor = Color(0xFFD32F2F);

  static final _priceFormat = NumberFormat('#,##0.##', 'en_IN');

  String _formatPrice(double price) => '₹${_priceFormat.format(price)}';

  List<PlanFeature> _displayFeatures(List<PlanFeature> features) =>
      features.where((f) => !f.isCategoryHeader).toList();

  List<PlanFeature> _visibleFeatures(List<PlanFeature> features) {
    final all = _displayFeatures(features);
    final limit = overviewFeatureLimit;
    if (compact || featuresExpanded || all.length <= limit) {
      return all;
    }
    return all.take(limit).toList();
  }

  int _hiddenCount(List<PlanFeature> features) =>
      _displayFeatures(features).length - overviewFeatureLimit;

  @override
  Widget build(BuildContext context) {
    final isGold = this.isGold;
    final plan = this.plan;
    final visibleFeatures = _visibleFeatures(features);
    final hiddenCount = _hiddenCount(features);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isGold ? AppColors.surface : _platinumBg,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: isGold ? const Color(0xFFE0E0E0) : const Color(0xFFB39DDB),
              width: isGold ? 1 : 1.5,
            ),
            boxShadow: isGold
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF7E57C2).withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(isGold, plan, pricing),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),
                ...visibleFeatures.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _FeatureListItem(
                      feature: f,
                      isGold: isGold,
                      checkColor: _checkColor,
                      crossColor: _crossColor,
                    ),
                  ),
                ),
                if (!compact && !featuresExpanded && hiddenCount > 0) ...[
                  InkWell(
                    onTap: onToggleFeatures,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        '+ $hiddenCount More Features ↓',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        if (plan.isMostPopular && !compact)
          Positioned(
            top: -10,
            right: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: AppRadius.smBorder,
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isGold, PricingPlan plan, PlanPricing pricing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: compact ? 36 : 44,
              height: compact ? 36 : 44,
              decoration: BoxDecoration(
                color: isGold ? _goldIconBg : _platinumIconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGold ? Icons.change_history : Icons.flag_outlined,
                color: isGold ? _goldIconColor : _platinumIconColor,
                size: compact ? 20 : 24,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                plan.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 18 : 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatPrice(pricing.originalPrice),
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatPrice(pricing.discountedPrice),
                style: TextStyle(
                  fontSize: compact ? 20 : 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Only ${_formatPrice(pricing.perMonthPrice)} per month',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 12 : 13,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: isGold
              ? OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 4,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(pricing.ctaLabel),
                )
              : FilledButton(
                  onPressed: onCtaPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 4,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(pricing.ctaLabel),
                ),
        ),
      ],
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  const _FeatureListItem({
    required this.feature,
    required this.isGold,
    required this.checkColor,
    required this.crossColor,
  });

  final PlanFeature feature;
  final bool isGold;
  final Color checkColor;
  final Color crossColor;

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
        color: included == true ? checkColor : crossColor,
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
