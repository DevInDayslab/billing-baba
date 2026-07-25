import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:flutter/material.dart';

class FeatureComparisonRow extends StatelessWidget {
  const FeatureComparisonRow({
    required this.feature,
    required this.isEven,
    super.key,
  });

  final PlanFeature feature;
  final bool isEven;

  static const _categoryBg = Color(0xFFF0F0F0);
  static const _evenRowBg = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    if (feature.isCategoryHeader) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        color: _categoryBg,
        child: Text(
          feature.category!,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    return Container(
      color: isEven ? _evenRowBg : AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    feature.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Tooltip(
                  message: feature.name,
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(child: _FeatureCell(feature: feature, isGold: true)),
          ),
          Expanded(
            child: Center(
              child: _FeatureCell(feature: feature, isGold: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCell extends StatelessWidget {
  const _FeatureCell({required this.feature, required this.isGold});

  final PlanFeature feature;
  final bool isGold;

  static const _checkColor = Color(0xFF2E7D32);
  static const _crossColor = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    final value = isGold ? feature.goldValue : feature.platinumValue;
    if (value != null) {
      return Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      );
    }

    final included = isGold ? feature.goldIncluded : feature.platinumIncluded;
    if (included == true) {
      return const Icon(Icons.check, color: _checkColor, size: 20);
    }
    return const Icon(Icons.close, color: _crossColor, size: 20);
  }
}
