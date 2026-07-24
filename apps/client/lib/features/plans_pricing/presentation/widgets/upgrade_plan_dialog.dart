import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/subscription/application/subscription_purchase.dart';
import 'package:billing_baba/features/subscription/models/subscription_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shows the upgrade-plan confirmation flow from Plans & Pricing.
Future<void> showUpgradePlanDialog(
  BuildContext context, {
  required PlanPlatform platform,
  required PlanDuration duration,
  required double upgradeAmount,
  required Future<void> Function() onPay,
  CurrentSubscriptionModel? currentSubscription,
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
        onPay: onPay,
        currentSubscription: currentSubscription,
      ),
    ),
  );
}

enum _UpgradeStep { confirm, reviewCheckout }

class UpgradePlanDialog extends StatefulWidget {
  const UpgradePlanDialog({
    required this.platform,
    required this.duration,
    required this.upgradeAmount,
    required this.onPay,
    this.currentSubscription,
    super.key,
  });

  final PlanPlatform platform;
  final PlanDuration duration;
  final double upgradeAmount;
  final Future<void> Function() onPay;
  final CurrentSubscriptionModel? currentSubscription;

  @override
  State<UpgradePlanDialog> createState() => _UpgradePlanDialogState();
}

class _UpgradePlanDialogState extends State<UpgradePlanDialog> {
  static const _dialogMaxWidth = 1100.0;

  static final _priceFormat = NumberFormat('#,##0.##', 'en_IN');

  _UpgradeStep _step = _UpgradeStep.confirm;
  var _payInProgress = false;

  String get _platformDurationLabel =>
      '${widget.platform.label} • ${widget.duration.label}';

  String _formatPrice(double price) => '₹${_priceFormat.format(price)}';

  void _proceedToCheckout() {
    setState(() => _step = _UpgradeStep.reviewCheckout);
  }

  Future<void> _startPayment() async {
    if (_payInProgress) {
      return;
    }
    setState(() => _payInProgress = true);
    Navigator.of(context).pop();
    await widget.onPay();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: switch (_step) {
          _UpgradeStep.confirm => _buildConfirmStep(),
          _UpgradeStep.reviewCheckout => _buildReviewCheckoutStep(),
        },
      ),
    );
  }

  Widget _buildConfirmStep() {
    return Column(
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
                      platformDurationLabel: _platformDurationLabel,
                      currentSubscription: widget.currentSubscription,
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
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ActivePlanColumn(
                      platformDurationLabel: _platformDurationLabel,
                      currentSubscription: widget.currentSubscription,
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
    );
  }

  Widget _buildReviewCheckoutStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DialogHeader(
          title: 'Review Order Summary',
          onClose: () => Navigator.of(context).pop(),
          leading: IconButton(
            onPressed: () => setState(() => _step = _UpgradeStep.confirm),
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Vyapar Platinum ($_platformDurationLabel)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatPrice(widget.upgradeAmount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.lg),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatPrice(widget.upgradeAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.radio_button_checked,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'UPI / Net Banking (Mock)',
                        style: TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        'Simulated payment — no real charge',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
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
                onPressed: _payInProgress ? null : _startPayment,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm + 4,
                  ),
                ),
                child: Text('Pay ${_formatPrice(widget.upgradeAmount)}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.onClose,
    this.leading,
  });

  final String title;
  final VoidCallback onClose;
  final Widget? leading;

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
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.xs),
          ],
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
    required this.platformDurationLabel,
    this.currentSubscription,
  });

  final String platformDurationLabel;
  final CurrentSubscriptionModel? currentSubscription;

  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
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
                      currentSubscription?.planName ?? 'No Plan',
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
              currentSubscription?.expiresAt == null
                  ? 'Annual plan • 365 days'
                  : 'Expiring on ${formatSubscriptionExpiry(currentSubscription!.expiresAt)}',
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
  const _UpgradePlanColumn({required this.platformDurationLabel});

  final String platformDurationLabel;

  static const _platinumBg = Color(0xFFF3F0FF);
  static const _platinumIconBg = Color(0xFFEDE7F6);
  static const _platinumIconColor = Color(0xFF5E35B1);

  @override
  Widget build(BuildContext context) {
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
              const Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Will expire on 02 July 2029',
                    style: TextStyle(
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
