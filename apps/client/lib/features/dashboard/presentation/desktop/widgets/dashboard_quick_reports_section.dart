import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_empty_state.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardQuickReportsSection extends StatelessWidget {
  const DashboardQuickReportsSection({required this.reports, super.key});

  final List<DashboardQuickReportModel> reports;

  @override
  Widget build(BuildContext context) {
    return DashboardMetricCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Quick Reports',
                  style: DashboardTypography.cardTitle,
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
                child: const Text(
                  'View All →',
                  style: DashboardTypography.link,
                ),
              ),
            ],
          ),
          const SizedBox(height: DashboardSpacing.headerGap),
          if (reports.isEmpty)
            const DashboardEmptyState(
              icon: Icons.description_outlined,
              title: 'No reports available',
              subtitle: 'Reports will appear here.',
            )
          else
            for (var i = 0; i < reports.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm + 4),
              _ReportCard(report: reports[i]),
            ],
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final DashboardQuickReportModel report;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconFor(report.key);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(report.route),
        borderRadius: AppRadius.smBorder,
        hoverColor: AppColors.background,
        splashColor: AppColors.background,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: DashboardMetricCard.borderColor),
            borderRadius: AppRadius.smBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _iconFor(String key) => switch (key) {
    'sale_report' => (Icons.bar_chart_outlined, AppColors.primary),
    'all_transactions' => (Icons.receipt_long_outlined, AppColors.secondary),
    'daybook' => (Icons.book_outlined, DashboardColors.incoming),
    'party_statement' => (Icons.people_outline, AppColors.error),
    _ => (Icons.description_outlined, AppColors.primary),
  };
}
