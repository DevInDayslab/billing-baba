import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Expanded selected-plan card for narrow (< 760 px) layouts.
class PlanCardCompact extends StatelessWidget {
  const PlanCardCompact({
    required this.plan,
    required this.pricing,
    required this.features,
    required this.isGold,
    required this.onViewAllFeatures,
    super.key,
  });

  final PricingPlan plan;
  final PlanPricing pricing;
  final List<PlanFeature> features;
  final bool isGold;
  final VoidCallback onViewAllFeatures;

  static const _selectedBorderColor = Color(0xFFE91E63);
  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);
  static const _platinumIconBg = Color(0xFFEDE7F6);
  static const _platinumIconColor = Color(0xFF5E35B1);
  static const _checkColor = Color(0xFF2E7D32);
  static const _crossColor = Color(0xFFD32F2F);
  static const _checkBadgeColor = Color(0xFF43A047);
  static const _compactFeatureLimit = 12;

  static final _priceFormat = NumberFormat('#,##0.##', 'en_IN');

  String _formatPrice(double price) => '₹${_priceFormat.format(price)}';

  List<PlanFeature> _displayFeatures() => features
      .where((f) => !f.isCategoryHeader)
      .take(_compactFeatureLimit)
      .toList();

  @override
  Widget build(BuildContext context) {
    final visibleFeatures = _displayFeatures();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: _selectedBorderColor, width: 2),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
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
              InkWell(
                onTap: onViewAllFeatures,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'View All Features',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -6,
          right: AppSpacing.md,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: _checkBadgeColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isGold ? _goldIconBg : _platinumIconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGold ? Icons.change_history : Icons.flag_outlined,
                color: isGold ? _goldIconColor : _platinumIconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                plan.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatPrice(pricing.originalPrice),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatPrice(pricing.discountedPrice),
                style: const TextStyle(
                  fontSize: 26,
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
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Collapsed selector row for the unselected plan in compact mode.
class PlanCompactSelectorRow extends StatelessWidget {
  const PlanCompactSelectorRow({
    required this.plan,
    required this.isGold,
    required this.onTap,
    super.key,
  });

  final PricingPlan plan;
  final bool isGold;
  final VoidCallback onTap;

  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);
  static const _platinumIconBg = Color(0xFFEDE7F6);
  static const _platinumIconColor = Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isGold ? _goldIconBg : _platinumIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGold ? Icons.change_history : Icons.flag_outlined,
                  color: isGold ? _goldIconColor : _platinumIconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
              ),
            ],
          ),
        ),
      ),
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
