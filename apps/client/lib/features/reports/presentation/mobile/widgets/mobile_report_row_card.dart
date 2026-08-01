import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_formatters.dart';
import 'package:billing_baba/features/reports/presentation/mobile/models/mobile_report_view_model.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Transaction-style list card for mobile reports.
class MobileReportRowCard extends StatelessWidget {
  const MobileReportRowCard({
    required this.row,
    super.key,
  });

  final MobileReportRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MobileCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: MobileReportTheme.accent.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (row.dateTime != null) ...[
                        const Gap(2),
                        Text(
                          formatMobileReportMetaDateTime(row.dateTime!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: MobileReportTheme.chipBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    row.reference,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: MobileReportTheme.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                for (var i = 0; i < row.columns.length; i++) ...[
                  if (i > 0) const Gap(AppSpacing.sm),
                  Expanded(
                    child: _ValueColumn(column: row.columns[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueColumn extends StatelessWidget {
  const _ValueColumn({required this.column});

  final MobileReportRowColumn column;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          column.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(AppSpacing.xs),
        Text(
          column.value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: column.valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
