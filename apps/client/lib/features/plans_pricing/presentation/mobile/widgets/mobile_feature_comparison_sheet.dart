import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/application/mobile_feature_comparison_data.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/application/mobile_plans_selection_provider.dart';
import 'package:billing_baba/features/plans_pricing/presentation/mobile/widgets/mobile_feature_comparison_widgets.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the Vyapar-style feature comparison bottom sheet (~90% height).
Future<void> showMobileFeatureComparisonSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PlansPricingViewData viewData,
  required Future<void> Function(PricingPlan plan) onPurchase,
}) {
  return showMobileBottomSheet<void>(
    context: context,
    heightFraction: 0.9,
    scrollBody: false,
    titleWidget: const _ComparisonSheetHeader(),
    footer: _ComparisonSheetFooter(
      viewData: viewData,
      onPurchase: onPurchase,
    ),
    builder: (_) => const SizedBox.expand(
      child: _FeatureComparisonTableBody(),
    ),
  );
}

class _ComparisonSheetHeader extends StatelessWidget {
  const _ComparisonSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Feature Comparison',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          color: AppColors.textSecondary,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _FeatureComparisonTableBody extends ConsumerWidget {
  const _FeatureComparisonTableBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(mobilePlansSelectionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileFeatureComparisonFilters(
          duration: selection.duration,
          platform: selection.platform,
          onChangeTap: () => _showFilterPicker(context, ref, selection),
        ),
        const SizedBox(height: AppSpacing.md),
        const MobileFeatureComparisonTableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: MobileFeatureComparisonData.items.length,
            itemBuilder: (context, index) {
              return MobileFeatureComparisonTableRow(
                item: MobileFeatureComparisonData.items[index],
                isEven: index.isEven,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterPicker(
    BuildContext context,
    WidgetRef ref,
    MobilePlansSelectionState selection,
  ) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Change Plan Options',
                    style: Theme.of(sheetContext).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Duration',
                    style: Theme.of(sheetContext).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      for (final duration in PlanDuration.values)
                        ChoiceChip(
                          label: Text(duration.label),
                          selected: selection.duration == duration,
                          onSelected: (_) {
                            ref
                                .read(mobilePlansSelectionProvider.notifier)
                                .setDuration(duration);
                            Navigator.of(sheetContext).pop();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Platform',
                    style: Theme.of(sheetContext).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      for (final platform in PlanPlatform.values)
                        ChoiceChip(
                          label: Text(platform.label),
                          selected: selection.platform == platform,
                          onSelected: (_) {
                            ref
                                .read(mobilePlansSelectionProvider.notifier)
                                .setPlatform(platform);
                            Navigator.of(sheetContext).pop();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ComparisonSheetFooter extends ConsumerWidget {
  const _ComparisonSheetFooter({
    required this.viewData,
    required this.onPurchase,
  });

  final PlansPricingViewData viewData;
  final Future<void> Function(PricingPlan plan) onPurchase;

  PricingPlan _planFor(PricingPlanType type, List<PricingPlan> plans) {
    return plans.firstWhere(
      (plan) => type == PricingPlanType.gold ? plan.isGold : !plan.isGold,
      orElse: () => plans.first,
    );
  }

  String _ctaLabel(PricingPlan plan, PlanPricing pricing) {
    final tier = plan.isGold ? PricingPlanType.gold : PricingPlanType.platinum;
    final tierLabel = tier.comparisonTierLabel;
    if (pricing.ctaLabel.startsWith('Renew ')) {
      return 'Renew $tierLabel';
    }
    if (pricing.ctaLabel.startsWith('Upgrade ')) {
      return 'Upgrade to $tierLabel';
    }
    return 'Get $tierLabel';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(mobilePlansSelectionProvider);
    final plan = _planFor(selection.selectedPlan, viewData.plans);
    final pricing = plan.pricingFor(selection.platform, selection.duration);
    final ctaLabel = _ctaLabel(plan, pricing);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MobilePlanTierSelector(
          selected: selection.selectedPlan,
          onChanged: ref.read(mobilePlansSelectionProvider.notifier).selectPlan,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              await onPurchase(plan);
              if (context.mounted) Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdBorder,
              ),
            ),
            child: Text(
              ctaLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
