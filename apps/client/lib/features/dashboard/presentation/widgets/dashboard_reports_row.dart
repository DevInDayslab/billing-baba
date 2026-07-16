import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardReportsRow extends StatelessWidget {
  const DashboardReportsRow({required this.reports, super.key});

  final List<DashboardQuickReportModel> reports;

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);

    return DashboardMetricCard(
      padding: metrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Most Used Reports',
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
                child: const Text('View All', style: DashboardTypography.link),
              ),
            ],
          ),
          SizedBox(height: metrics.gap),
          Expanded(child: _ReportsChips(reports: reports, gap: metrics.gap)),
        ],
      ),
    );
  }
}

class _ReportsChips extends StatelessWidget {
  const _ReportsChips({required this.reports, required this.gap});

  final List<DashboardQuickReportModel> reports;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'No reports available',
          style: DashboardTypography.metadata,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < reports.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: _ReportChip(report: reports[i])),
        ],
      ],
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({required this.report});

  final DashboardQuickReportModel report;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(report.route),
        borderRadius: DashboardDecor.cardRadius,
        hoverColor: AppColors.background,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: DashboardMetricCard.borderColor),
            borderRadius: DashboardDecor.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: DashboardTypography.supportingLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
