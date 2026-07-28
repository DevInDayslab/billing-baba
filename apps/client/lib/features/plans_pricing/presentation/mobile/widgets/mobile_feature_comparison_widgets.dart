import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/application/mobile_feature_comparison_data.dart';
import 'package:flutter/material.dart';

const _checkColor = Color(0xFF2E7D32);
const _crossColor = Color(0xFFD32F2F);

/// Renders a single cell in the feature comparison table.
class MobileFeatureComparisonCell extends StatelessWidget {
  const MobileFeatureComparisonCell({
    required this.value,
    super.key,
  });

  final MobileFeatureCellValue value;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      MobileFeatureIncluded() => const Icon(Icons.check, color: _checkColor, size: 20),
      MobileFeatureExcluded() => const Icon(Icons.close, color: _crossColor, size: 20),
      MobileFeatureText(:final value) => Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    };
  }
}

/// Table header row: Feature | Silver | Gold.
class MobileFeatureComparisonTableHeader extends StatelessWidget {
  const MobileFeatureComparisonTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Feature',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Silver',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Gold',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single feature row in the comparison table.
class MobileFeatureComparisonTableRow extends StatelessWidget {
  const MobileFeatureComparisonTableRow({
    required this.item,
    required this.isEven,
    super.key,
  });

  final MobileFeatureComparisonItem item;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? const Color(0xFFFAFAFA) : AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: MobileFeatureComparisonCell(value: item.silver),
            ),
          ),
          Expanded(
            child: Center(
              child: MobileFeatureComparisonCell(value: item.gold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Silver / Gold plan tier selector for comparison sheet footer.
class MobilePlanTierSelector extends StatelessWidget {
  const MobilePlanTierSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final PricingPlanType selected;
  final ValueChanged<PricingPlanType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TierChip(
            label: PricingPlanType.gold.comparisonTierLabel,
            isSelected: selected == PricingPlanType.gold,
            onTap: () => onChanged(PricingPlanType.gold),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _TierChip(
            label: PricingPlanType.platinum.comparisonTierLabel,
            isSelected: selected == PricingPlanType.platinum,
            onTap: () => onChanged(PricingPlanType.platinum),
          ),
        ),
      ],
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
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
        borderRadius: AppRadius.mdBorder,
        border: Border.all(
          color: isSelected ? const Color(0xFFE91E63) : const Color(0xFFE0E0E0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
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

/// Filter chips row: duration | platform | Change.
class MobileFeatureComparisonFilters extends StatelessWidget {
  const MobileFeatureComparisonFilters({
    required this.duration,
    required this.platform,
    required this.onChangeTap,
    super.key,
  });

  final PlanDuration duration;
  final PlanPlatform platform;
  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(label: duration.label),
        const SizedBox(width: AppSpacing.sm),
        _FilterChip(label: platform.label),
        const SizedBox(width: AppSpacing.sm),
        _FilterChip(label: 'Change', onTap: onChangeTap, showChevron: true),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.onTap,
    this.showChevron = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
