import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// You'll Get / You'll Give balance row (Vyapar-style).
class MobileDashboardBalanceCards extends StatelessWidget {
  const MobileDashboardBalanceCards({
    required this.overview,
    required this.onYoullGetTap,
    required this.onYoullGiveTap,
    super.key,
  });

  final DashboardOverviewModel overview;
  final VoidCallback? onYoullGetTap;
  final VoidCallback? onYoullGiveTap;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BalanceCard(
            title: "You'll Get",
            amount: _currency.format(overview.totalReceivable),
            subtitle: overview.receivablePartyCount == 0
                ? 'No receivables'
                : '${overview.receivablePartyCount} parties',
            backgroundColor: const Color(0xFFE8F5E9),
            accentColor: const Color(0xFF2E7D32),
            icon: Icons.south_west_rounded,
            onTap: onYoullGetTap,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _BalanceCard(
            title: "You'll Give",
            amount: _currency.format(overview.totalPayable),
            subtitle: overview.payablePartyCount == 0
                ? 'No payables'
                : '${overview.payablePartyCount} parties',
            backgroundColor: const Color(0xFFFFEBEE),
            accentColor: const Color(0xFFC62828),
            icon: Icons.north_east_rounded,
            onTap: onYoullGiveTap,
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String amount;
  final String subtitle;
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MobileCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      borderColor: backgroundColor,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            amount,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
