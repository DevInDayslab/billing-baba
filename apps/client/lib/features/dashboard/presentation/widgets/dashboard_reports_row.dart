import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/layout/dashboard_navigation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/models/dashboard_model.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardReportsRow extends ConsumerWidget {
  const DashboardReportsRow({required this.reports, super.key});

  final List<DashboardQuickReportModel> reports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = DashboardLayoutScope.of(context);

    return DashboardMetricCard(
      padding: EdgeInsets.fromLTRB(
        metrics.padding,
        metrics.padding * 1.75,
        metrics.padding,
        metrics.padding * 0.75,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Most Used Reports',
                  style: DashboardTypography.supportingLabel.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
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
                child: const Text('View All', style: DashboardTypography.link),
              ),
            ],
          ),
          SizedBox(height: metrics.gap),
          Expanded(
            child: _ReportsChips(reports: reports, gap: metrics.gap, ref: ref),
          ),
        ],
      ),
    );
  }
}

class _ReportsChips extends StatelessWidget {
  const _ReportsChips({
    required this.reports,
    required this.gap,
    required this.ref,
  });

  final List<DashboardQuickReportModel> reports;
  final double gap;
  final WidgetRef ref;

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
      children: [
        for (var i = 0; i < reports.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
           Expanded(child: _ReportChip(report: reports[i], ref: ref)),
        ],
      ],
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({required this.report, required this.ref});

  final DashboardQuickReportModel report;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => DashboardNavigation.openQuickReport(
          context,
          ref,
          key: report.key,
        ),
        borderRadius: DashboardDecor.cardRadius,
        hoverColor: AppColors.background,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: DashboardMetricCard.borderColor),
            borderRadius: DashboardDecor.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4, vertical: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: DashboardTypography.supportingLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
