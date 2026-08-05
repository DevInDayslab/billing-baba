import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Horizontal scrolling financial asset cards.
class MobileFinancialAssetsRow extends StatelessWidget {
  const MobileFinancialAssetsRow({
    required this.dashboard,
    super.key,
  });

  final DashboardModel dashboard;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String? _trendLabel(List<DashboardTrendPointModel> points, String period) {
    if (points.length < 2) return null;
    final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
    final delta = sorted.last.amount - sorted[sorted.length - 2].amount;
    if (delta == 0) return null;
    final arrow = delta > 0 ? '▲' : '▼';
    return '$arrow ${_currency.format(delta.abs())} $period';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final salesTrend = _trendLabel(
      dashboard.sales.trendPoints,
      'this month',
    );

    final items = [
      _AssetItem(
        title: 'Stock Value',
        amount: _currency.format(dashboard.inventory.totalStockValue),
        trend: salesTrend,
        icon: Icons.view_in_ar_outlined,
        color: primary,
        cardColor: const Color(0xFFF5F1FF),
        onTap: () => context.push(AppRoutes.items),
      ),
      _AssetItem(
        title: 'Cash in Hand',
        amount: _currency.format(dashboard.finance.cashIn),
        trend: _trendLabel(dashboard.sales.trendPoints, 'today'),
        icon: Icons.payments_outlined,
        color: AppColors.success,
        cardColor: const Color(0xFFEEF7EF),
        onTap: () => context.push(AppRoutes.reports),
      ),
      _AssetItem(
        title: 'Bank / UPI Payments',
        amount: _currency.format(dashboard.finance.cashOut),
        trend: salesTrend,
        icon: Icons.account_balance_outlined,
        color: const Color(0xFF1976D2),
        cardColor: const Color(0xFFEEF4FB),
        onTap: () => context.push(AppRoutes.reports),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        0,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Financial Assets',
                    style: AppTypography.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.reports),
                  child: Text(
                    'View All >',
                    style: AppTypography.inter(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => _AssetCard(item: items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetItem {
  const _AssetItem({
    required this.title,
    required this.amount,
    required this.trend,
    required this.icon,
    required this.color,
    required this.cardColor,
    this.onTap,
  });

  final String title;
  final String amount;
  final String? trend;
  final IconData icon;
  final Color color;
  final Color cardColor;
  final VoidCallback? onTap;
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.item});

  final _AssetItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: AppRadius.cardBorder,
        child: Ink(
          width: 168,
          decoration: BoxDecoration(
            color: item.cardColor,
            borderRadius: AppRadius.cardBorder,
            border: Border.all(color: item.color.withValues(alpha: 0.16)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, size: 36, color: item.color),
              ),
              // const Spacer(),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: AppTypography.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                item.amount,
                style: AppTypography.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.trend != null) ...[
                const SizedBox(height: 2),
                Text(
                  item.trend!,
                  style: AppTypography.inter(
                    fontSize: 9,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
