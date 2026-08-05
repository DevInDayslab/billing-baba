import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Money section — To Collect / To Pay cards.
class MobileMoneyCards extends StatelessWidget {
  const MobileMoneyCards({
    required this.overview,
    required this.onYoullGetTap,
    required this.onYoullGiveTap,
    this.onHeaderTap,
    super.key,
  });

  final DashboardOverviewModel overview;
  final VoidCallback? onYoullGetTap;
  final VoidCallback? onYoullGiveTap;
  final VoidCallback? onHeaderTap;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final total = overview.totalReceivable + overview.totalPayable;
    final receiveRatio = total > 0 ? overview.totalReceivable / total : 0.0;
    final payRatio = total > 0 ? overview.totalPayable / total : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: AppRadius.smBorder,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Money',
                      style: AppTypography.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MoneyCard(
                    title: 'To Collect',
                    amount: _currency.format(overview.totalReceivable),
                    subtitle: '${overview.receivablePartyCount} Parties',
                    progress: receiveRatio.clamp(0.0, 1.0),
                    color: AppColors.success,
                    cardColor: AppColors.successSoft,
                    onTap: onYoullGetTap,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MoneyCard(
                    title: 'To Pay',
                    amount: _currency.format(overview.totalPayable),
                    subtitle: '${overview.payablePartyCount} Parties',
                    progress: payRatio.clamp(0.0, 1.0),
                    color: AppColors.danger,
                    cardColor: AppColors.dangerSoft,
                    onTap: onYoullGiveTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.progress,
    required this.color,
    required this.cardColor,
    this.onTap,
  });

  final String title;
  final String amount;
  final String subtitle;
  final double progress;
  final Color color;
  final Color cardColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final percentLabel = '${(progress * 100).round()}%';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: AppRadius.cardBorder,
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                amount,
                style: AppTypography.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: progress),
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 4,
                            backgroundColor: AppColors.surface.withValues(
                              alpha: 0.65,
                            ),
                            color: color,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    percentLabel,
                    style: AppTypography.inter(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
