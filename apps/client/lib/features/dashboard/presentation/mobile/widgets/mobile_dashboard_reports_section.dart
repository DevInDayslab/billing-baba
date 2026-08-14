import 'package:billing_baba/features/dashboard/dashboard_navigation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_dashboard_mock_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Most Used Reports grid with See All action.
class MobileDashboardReportsSection extends ConsumerWidget {
  const MobileDashboardReportsSection({
    required this.reports,
    super.key,
  });

  final List<DashboardQuickReportModel> reports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = reports.isEmpty
        ? MobileDashboardMockData.defaultReports
        : _normalizeReports(reports);

    return MobileCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Most Used Reports',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.reports),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.4,
            children: [
              for (final report in items.take(4))
                _ReportTile(
                  report: report,
                  onTap: () => _openReport(context, ref, report),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<DashboardQuickReportModel> _normalizeReports(
    List<DashboardQuickReportModel> source,
  ) {
    if (source.length >= 4) return source.take(4).toList();

    final merged = [...source];
    for (final fallback in MobileDashboardMockData.defaultReports) {
      if (merged.length >= 4) break;
      if (!merged.any((r) => r.title == fallback.title)) {
        merged.add(fallback);
      }
    }
    return merged;
  }

  void _openReport(
    BuildContext context,
    WidgetRef ref,
    DashboardQuickReportModel report,
  ) {
    if (report.key == 'balance_sheet' || report.key == 'profit_loss') {
      context.go(AppRoutes.reports);
      return;
    }
    if (report.key == 'purchase_report') {
      context.go(AppRoutes.reportsPurchase);
      return;
    }
    DashboardNavigation.openQuickReport(context, ref, key: report.key);
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.report,
    required this.onTap,
  });

  final DashboardQuickReportModel report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _iconFor(report.key);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8EAED)),
            borderRadius: AppRadius.mdBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    report.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _iconFor(String key) => switch (key) {
    'sale_report' => (Icons.bar_chart_rounded, AppColors.primary),
    'purchase_report' => (
      Icons.shopping_cart_outlined,
      const Color(0xFFEF6C00),
    ),
    'balance_sheet' => (
      Icons.account_balance_outlined,
      const Color(0xFF00897B),
    ),
    'profit_loss' => (Icons.pie_chart_outline_rounded, const Color(0xFF7B1FA2)),
    _ => (Icons.description_outlined, AppColors.primary),
  };
}
