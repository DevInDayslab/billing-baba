import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/application/dashboard_provider.dart';
import 'package:billing_baba/features/dashboard/models/requests/dashboard_requests.dart';
import 'package:billing_baba/features/reports/presentation/mobile/mobile_report_detail_page.dart';
import 'package:billing_baba/shared/chart/chart_axis_formatters.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_offline_banner.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileReportsPage extends ConsumerWidget {
  const MobileReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final period = ref.watch(dashboardPeriodFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MobileAppBar(
        title: 'Reports',
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: Column(
        children: [
          const MobileOfflineBanner(
            message: 'Detailed reports refresh when you pull to sync data.',
          ),
          Expanded(
            child: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppError(
          message: error.toString(),
          onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
        ),
        data: (viewState) {
          final dashboard = viewState.dashboard;
          return RefreshIndicator(
            onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _PeriodSelector(
                  period: period,
                  onChanged: (value) =>
                      ref.read(dashboardPeriodFilterProvider.notifier).setPeriod(value),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ReportCard(
                  title: 'Sales',
                  value: ChartAxisFormatters.formatCurrency(
                    dashboard.sales.totalAmount,
                  ),
                  subtitle:
                      '${dashboard.sales.invoiceCount} invoices · Balance ${ChartAxisFormatters.formatCurrency(dashboard.sales.balanceAmount)}',
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportCard(
                  title: 'Purchases',
                  value: ChartAxisFormatters.formatCurrency(
                    dashboard.purchases.totalAmount,
                  ),
                  subtitle: '${dashboard.purchases.billCount} bills',
                  icon: Icons.shopping_cart_outlined,
                  color: const Color(0xFFE65100),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportCard(
                  title: 'Receivable',
                  value: ChartAxisFormatters.formatCurrency(
                    dashboard.overview.totalReceivable,
                  ),
                  subtitle:
                      '${dashboard.overview.receivablePartyCount} parties',
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFF1976D2),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportCard(
                  title: 'Payable',
                  value: ChartAxisFormatters.formatCurrency(
                    dashboard.overview.totalPayable,
                  ),
                  subtitle: '${dashboard.overview.payablePartyCount} parties',
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFC62828),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportCard(
                  title: 'Cash Flow',
                  value: ChartAxisFormatters.formatCurrency(
                    dashboard.finance.cashIn - dashboard.finance.cashOut,
                  ),
                  subtitle:
                      'In ${ChartAxisFormatters.formatCurrency(dashboard.finance.cashIn)} · Out ${ChartAxisFormatters.formatCurrency(dashboard.finance.cashOut)}',
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFF5D5FEF),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportCard(
                  title: 'Expenses',
                  value: ChartAxisFormatters.formatCurrency(
                    dashboard.finance.expenses,
                  ),
                  subtitle: 'Total expenses for selected period',
                  icon: Icons.money_off_outlined,
                  color: const Color(0xFF9E9E9E),
                ),
                const SizedBox(height: AppSpacing.md),
                _ReportCard(
                  title: 'Stock Value',
                  value: ChartAxisFormatters.formatCurrency(
                    dashboard.inventory.totalStockValue,
                  ),
                  subtitle:
                      '${dashboard.inventory.lowStockCount} low stock · ${dashboard.inventory.negativeStockCount} negative',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF43A047),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Detailed reports',
                  style: AppTypography.inter(
                    fontSize: AppTypography.bodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _DetailedReportTile(
                  title: 'Party outstanding',
                  onTap: () => _openReport(
                    context,
                    MobileReportDetailType.partyOutstanding,
                  ),
                ),
                _DetailedReportTile(
                  title: 'Stock summary',
                  onTap: () => _openReport(
                    context,
                    MobileReportDetailType.stockSummary,
                  ),
                ),
                _DetailedReportTile(
                  title: 'Day book',
                  onTap: () => _openReport(
                    context,
                    MobileReportDetailType.dayBook,
                  ),
                ),
                _DetailedReportTile(
                  title: 'Profit & loss',
                  onTap: () => _openReport(
                    context,
                    MobileReportDetailType.profitLoss,
                  ),
                ),
                _DetailedReportTile(
                  title: 'GSTR-1',
                  onTap: () => _openReport(
                    context,
                    MobileReportDetailType.gstr1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  void _openReport(BuildContext context, MobileReportDetailType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MobileReportDetailPage(type: type),
      ),
    );
  }
}

class _DetailedReportTile extends StatelessWidget {
  const _DetailedReportTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.period,
    required this.onChanged,
  });

  final DashboardPeriod period;
  final ValueChanged<DashboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DashboardPeriod.values
            .where((value) => value != DashboardPeriod.custom)
            .map((value) {
          final selected = value == period;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(_periodLabel(value)),
              selected: selected,
              onSelected: (_) => onChanged(value),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _periodLabel(DashboardPeriod period) => switch (period) {
    DashboardPeriod.today => 'Today',
    DashboardPeriod.thisWeek => 'This Week',
    DashboardPeriod.thisMonth => 'This Month',
    DashboardPeriod.thisYear => 'This Year',
    DashboardPeriod.allTime => 'All Time',
    DashboardPeriod.custom => 'Custom',
  };
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
