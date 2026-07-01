import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:billing_baba/features/plans_pricing/presentation/widgets/upgrade_plan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows the license info modal from Plans & Pricing overflow menu.
Future<void> showLicenseInfoDialog(
  BuildContext context, {
  required PlanPlatform platform,
  required PlanDuration duration,
  required double upgradeAmount,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LicenseInfoDialog(
        platform: platform,
        duration: duration,
        upgradeAmount: upgradeAmount,
      ),
    ),
  );
}

class LicenseInfoDialog extends StatelessWidget {
  const LicenseInfoDialog({
    required this.platform,
    required this.duration,
    required this.upgradeAmount,
    super.key,
  });

  final PlanPlatform platform;
  final PlanDuration duration;
  final double upgradeAmount;

  static const _syncCompanyId =
      '7987016325__t_2024_10_05_00_16_26_s5iu.vyp';
  static const _upgradeBannerBg = Color(0xFFE8F1FF);
  static const _goldIconBg = Color(0xFFFFF3E0);
  static const _goldIconColor = Color(0xFFE65100);
  static const _expiryColor = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 650),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DialogHeader(onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.sm),
              _SubheaderRow(syncCompanyId: _syncCompanyId),
              const SizedBox(height: AppSpacing.lg),
              _PlanDetailsCard(
                goldIconBg: _goldIconBg,
                goldIconColor: _goldIconColor,
                expiryColor: _expiryColor,
              ),
              const SizedBox(height: AppSpacing.md),
              _UpgradeBanner(
                bannerBg: _upgradeBannerBg,
                onUpgrade: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  showUpgradePlanDialog(
                    navigator.context,
                    platform: platform,
                    duration: duration,
                    upgradeAmount: upgradeAmount,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'View License Info',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

class _SubheaderRow extends StatelessWidget {
  const _SubheaderRow({required this.syncCompanyId});

  final String syncCompanyId;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 12,
      color: AppColors.textSecondary,
      height: 1.4,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        const Text('Device ID: SFPLBBC7MQXVJZ1V', style: labelStyle),
        const Text('•', style: labelStyle),
        const Text('License ID: 0060-6781-5583', style: labelStyle),
        const Text('•', style: labelStyle),
        const Text('Sync Company ID: ', style: labelStyle),
        Tooltip(
          message: 'Click to Copy',
          preferBelow: false,
          verticalOffset: 16,
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: syncCompanyId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sync Company ID copied'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              syncCompanyId,
              style: labelStyle.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanDetailsCard extends StatelessWidget {
  const _PlanDetailsCard({
    required this.goldIconBg,
    required this.goldIconColor,
    required this.expiryColor,
  });

  final Color goldIconBg;
  final Color goldIconColor;
  final Color expiryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: goldIconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.change_history,
                  color: goldIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Vyapar Gold',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PlatformExpiryColumn(
                  platform: 'Desktop  •  3 Years',
                  expiry: "(Expires on 3 Dec '26 ; 156 days left)",
                  expiryColor: expiryColor,
                ),
              ),
              Expanded(
                child: _PlatformExpiryColumn(
                  platform: 'Mobile  •  3 Years',
                  expiry: "(Expires on 18 Nov '26 ; 141 days left)",
                  expiryColor: expiryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _DashedDivider(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '•  MANUFACTURING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformExpiryColumn extends StatelessWidget {
  const _PlatformExpiryColumn({
    required this.platform,
    required this.expiry,
    required this.expiryColor,
  });

  final String platform;
  final String expiry;
  final Color expiryColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          platform,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          expiry,
          style: TextStyle(
            fontSize: 12,
            color: expiryColor,
          ),
        ),
      ],
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
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashGap)).floor();
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

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({
    required this.bannerBg,
    required this.onUpgrade,
  });

  final Color bannerBg;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Upgrade now & get upto 15% OFF on Platinum:',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(
            onPressed: onUpgrade,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
