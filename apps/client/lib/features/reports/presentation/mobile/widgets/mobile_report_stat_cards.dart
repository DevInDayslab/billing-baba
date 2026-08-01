import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/mobile_report_view_model.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_scaffold.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Three summary stat cards shown below the filter header.
class MobileReportStatCards extends StatelessWidget {
  const MobileReportStatCards({
    required this.metrics,
    super.key,
  });

  final List<MobileReportSummaryMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return MobileReportMetricsBand(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0) const Gap(AppSpacing.sm),
              Expanded(child: _StatCard(metric: metrics[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.metric});

  final MobileReportSummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    return MobileCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: metric.valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
