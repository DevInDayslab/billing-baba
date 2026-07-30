import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/subscription/application/current_subscription_provider.dart';
import 'package:billing_baba/features/subscription/application/plans_pricing_view_provider.dart';
import 'package:billing_baba/features/subscription/application/subscription_error_mapper.dart';
import 'package:billing_baba/features/subscription/domain/models/current_subscription.dart';
import 'package:billing_baba/features/subscription/domain/models/subscription_plan_type.dart';
import 'package:billing_baba/features/subscription/domain/subscription_plan_metadata.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/review_order_summary_dialog.dart';
import 'package:billing_baba/features/subscription/presentation/desktop/review_order_summary_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Shows the upgrade-plan confirmation flow from Plans & Pricing.
Future<void> showUpgradePlanDialog(
  BuildContext context, {
  required PlanPlatform platform,
  required PlanDuration duration,
  required double upgradeAmount,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: UpgradePlanDialog(
        platform: platform,
        duration: duration,
        upgradeAmount: upgradeAmount,
      ),
    ),
  );
}

class UpgradePlanDialog extends ConsumerStatefulWidget {
  const UpgradePlanDialog({
    required this.platform,
    required this.duration,
    required this.upgradeAmount,
    super.key,
  });

  final PlanPlatform platform;
  final PlanDuration duration;
  final double upgradeAmount;

  @override
  ConsumerState<UpgradePlanDialog> createState() => _UpgradePlanDialogState();
}

class _UpgradePlanDialogState extends ConsumerState<UpgradePlanDialog> {
  static const _dialogMaxWidth = 1100.0;

  String get _platformDurationLabel =>
      '${widget.platform.label} • ${widget.duration.label}';

  void _proceedToCheckout() {
    final viewData = ref.read(plansPricingViewProvider).asData?.value;
    final platinumPlan = viewData?.plans
        .where((plan) => !plan.isGold)
        .firstOrNull;
    final pricing = platinumPlan?.pricingFor(widget.platform, widget.duration);
    final metadata = metadataFor(SubscriptionPlanType.platinum);

    final input = ReviewOrderSummaryInput(
      planType: SubscriptionPlanType.platinum,
      planName: platinumPlan?.name ?? 'Platinum',
      platform: widget.platform,
      duration: widget.duration,
      discountedPrice: widget.upgradeAmount,
      originalPrice: pricing?.originalPrice ?? widget.upgradeAmount,
      licenseType: metadata.licenseType,
      deviceLimit: metadata.deviceLimit,
      durationLabel: widget.duration.label,
    );

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    Navigator.of(context).pop();
    unawaited(showReviewOrderSummaryDialog(rootContext, ref, input: input));
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: _buildConfirmStep(),
      ),
    );
  }

  Widget _buildConfirmStep() {
    final currentAsync = ref.watch(currentSubscriptionStateProvider);

    return currentAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(SubscriptionErrorMapper.messageFor(error)),
      ),
      data: (current) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DialogHeader(
            title: 'Upgrade your Plan',
            onClose: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 640;

                if (isNarrow) {
                  return Column(
                    children: [
                      _ActivePlanColumn(
                        current: current,
                        platformDurationLabel: _platformDurationLabel,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Icon(
                        Icons.arrow_downward,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _UpgradePlanColumn(
                        platformDurationLabel: _platformDurationLabel,
                        duration: widget.duration,
                        upgradeAmount: widget.upgradeAmount,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ActivePlanColumn(
                        current: current,
                        platformDurationLabel: _platformDurationLabel,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
                    ),
                    Expanded(
                      child: _UpgradePlanColumn(
                        platformDurationLabel: _platformDurationLabel,
                        duration: widget.duration,
                        upgradeAmount: widget.upgradeAmount,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _ConfirmBottomBar(
            onCancel: () => Navigator.of(context).pop(),
            onProceed: _proceedToCheckout,
          ),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LabelPill extends StatelessWidget {
  const _LabelPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ActivePlanColumn extends StatelessWidget {
  const _ActivePlanColumn({
    required this.current,
    required this.platformDurationLabel,
  });

  final CurrentSubscription current;
  final String platformDurationLabel;

  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);
  static final _dateFormat = DateFormat('dd MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    final planName = current.hasActivePlan
        ? 'Vyapar ${current.planName}'
        : 'No active plan';
    final expiryLabel = current.expiresAt != null
        ? 'Expiring on ${_dateFormat.format(current.expiresAt!)}'
        : 'No expiry date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LabelPill(label: 'Active Plan'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _goldIconBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.change_history,
                      color: _goldIconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      planName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                platformDurationLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _DashedDivider(),
              const SizedBox(height: AppSpacing.md),
              const Text(
                '•  Manufacturing Add-on',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.schedule,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              expiryLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UpgradePlanColumn extends StatelessWidget {
  const _UpgradePlanColumn({
    required this.platformDurationLabel,
    required this.duration,
    required this.upgradeAmount,
  });

  final String platformDurationLabel;
  final PlanDuration duration;
  final double upgradeAmount;

  static const _platinumBg = Color(0xFFF3F0FF);
  static const _platinumIconBg = Color(0xFFEDE7F6);
  static const _platinumIconColor = Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context) {
    final durationDays = duration == PlanDuration.threeYears ? 365 * 3 : 365;
    final projectedExpiry = DateTime.now().add(Duration(days: durationDays));
    final expiryLabel =
        'Will expire on ${DateFormat('dd MMMM yyyy').format(projectedExpiry)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LabelPill(label: 'Upgrade Plan'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _platinumBg,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: const Color(0xFFB39DDB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _platinumIconBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.change_history,
                      color: _platinumIconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Vyapar Platinum',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                platformDurationLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    expiryLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfirmBottomBar extends StatelessWidget {
  const _ConfirmBottomBar({
    required this.onCancel,
    required this.onProceed,
  });

  final VoidCallback onCancel;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'You will not be able to downgrade your plan later.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm + 4,
              ),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: onProceed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm + 4,
              ),
            ),
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashGap = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashGap))
            .floor();
        return Row(
          children: List.generate(dashCount, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < dashCount - 1 ? dashGap : 0,
              ),
              child: Container(
                width: dashWidth,
                height: 1,
                color: Colors.grey.shade300,
              ),
            );
          }),
        );
      },
    );
  }
}
