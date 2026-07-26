import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardOverviewSection extends StatelessWidget {
  const DashboardOverviewSection({
    required this.overview,
    required this.onReceivableTap,
    required this.onPayableTap,
    super.key,
  });

  final DashboardOverviewModel overview;
  final VoidCallback onReceivableTap;
  final VoidCallback onPayableTap;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _OverviewMetricCard(
            title: 'Total Receivable',
            amount: overview.totalReceivable,
            subtitle: overview.receivablePartyCount == 0
                ? "You don't have any receivables as of now."
                : _partyCountLabel(overview.receivablePartyCount),
            icon: Icons.south_west,
            iconColor: DashboardColors.incoming,
            iconBackground: DashboardColors.incomingBg,
            onTap: onReceivableTap,
            currencyFormat: _currencyFormat,
            padding: metrics.cardPadding,
          ),
        ),
        SizedBox(width: metrics.gap),
        Expanded(
          child: _OverviewMetricCard(
            title: 'Total Payable',
            amount: overview.totalPayable,
            subtitle: overview.payablePartyCount == 0
                ? "You don't have any payables as of now."
                : _partyCountLabel(overview.payablePartyCount),
            icon: Icons.north_east_rounded,
            iconColor: DashboardColors.outgoing,
            iconBackground: DashboardColors.outgoingBg,
            onTap: onPayableTap,
            currencyFormat: _currencyFormat,
            padding: metrics.cardPadding,
          ),
        ),
      ],
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.currencyFormat,
    required this.padding,
    this.onTap,
  });

  final String title;
  final double amount;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final NumberFormat currencyFormat;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final verticalPadding = padding.top * 0.5;

    return DashboardMetricCard(
      padding: EdgeInsets.fromLTRB(
        padding.left,
        verticalPadding,
        padding.right,
        verticalPadding,
      ),
      onTap: onTap,
      child: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const iconSize = AppIconSize.lg;
            const itemGap = AppSpacing.xs;

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs,right: iconSize + 4),
                      child: Text(
                        title,
                        style: DashboardTypography.supportingLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: itemGap),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppEllipsisText(
                          currencyFormat.format(amount),
                          style: DashboardTypography.kpiValue,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: DashboardTypography.supportingLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _KpiDirectionIcon(
                    icon: icon,
                    color: iconColor,
                    background: iconBackground,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KpiDirectionIcon extends StatelessWidget {
  const _KpiDirectionIcon({
    required this.icon,
    required this.color,
    required this.background,
  }) : size = 24;

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

String _partyCountLabel(int count) {
  if (count == 1) return 'From 1 Party';
  return 'From $count Parties';
}
