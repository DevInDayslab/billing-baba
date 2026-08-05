import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/presentation/mobile/application/mobile_report_formatters.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_filter_sheet.dart';
import 'package:billing_baba/features/reports/presentation/mobile/widgets/mobile_report_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_card.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Period, date range, filter chips, and filters button for mobile reports.
class MobileReportFilterHeader extends ConsumerWidget {
  const MobileReportFilterHeader({
    required this.onFiltersChanged,
    super.key,
    this.extraChips = const [],
  });

  /// Called after period, date range, or sheet filters change so data reloads.
  final VoidCallback onFiltersChanged;

  /// Optional report-specific chips (e.g. "Txns Type - Sale").
  final List<String> extraChips;

  static const List<ReportPeriod> _periodOptions = [
    ReportPeriod.thisMonth,
    ReportPeriod.lastMonth,
    ReportPeriod.thisWeek,
    ReportPeriod.lastWeek,
    ReportPeriod.today,
    ReportPeriod.yesterday,
    ReportPeriod.thisQuarter,
    ReportPeriod.thisYear,
    ReportPeriod.allTime,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final range = filters.effectiveDateRange;
    final theme = Theme.of(context);
    final filterChips = buildMobileReportFilterChips(
      filters,
      extraChips: extraChips,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: MobileCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: MobileReportTheme.chipBackground,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(color: MobileReportTheme.chipBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _FilterTapArea(
                      label: filters.periodLabel,
                      icon: Icons.keyboard_arrow_down_rounded,
                      onTap: () => unawaited(_pickPeriod(context, ref)),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: MobileReportTheme.divider,
                  ),
                  Expanded(
                    flex: 3,
                    child: _FilterTapArea(
                      label: formatMobileReportDateRange(
                        range.start,
                        range.end,
                      ),
                      icon: Icons.calendar_today_outlined,
                      iconSize: 15,
                      onTap: () => unawaited(_pickDateRange(context, ref)),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSpacing.md),
            Row(
              children: [
                Text(
                  'Filters Applied',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () => unawaited(_openFilters(context, ref)),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Filters'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: MobileReportTheme.accentSoft,
                    foregroundColor: MobileReportTheme.accent,
                  ),
                ),
              ],
            ),
            if (filterChips.isNotEmpty) ...[
              const Gap(AppSpacing.sm),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterChips.length,
                  separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return _FilterChip(label: filterChips[index]);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openFilters(BuildContext context, WidgetRef ref) async {
    final filters = ref.read(reportFiltersProvider);
    final draft = await showMobileReportFilterSheet(
      context: context,
      initial: filters,
    );
    if (draft == null) return;
    applyMobileReportFilterDraft(ref, draft);
    onFiltersChanged();
  }

  Future<void> _pickPeriod(BuildContext context, WidgetRef ref) async {
    final filters = ref.read(reportFiltersProvider);
    final selected = await showMobileOptionSheet<ReportPeriod>(
      context: context,
      title: 'Period',
      selected: filters.period,
      options: [
        for (final period in _periodOptions)
          MobileOption(value: period, label: period.label),
      ],
    );
    if (selected == null) return;
    ref.read(reportFiltersProvider.notifier).setPeriod(selected);
    onFiltersChanged();
  }

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
    final filters = ref.read(reportFiltersProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: filters.effectiveDateRange,
    );
    if (picked == null) return;
    ref.read(reportFiltersProvider.notifier).setCustomDateRange(picked);
    onFiltersChanged();
  }
}

class _FilterTapArea extends StatelessWidget {
  const _FilterTapArea({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconSize = 20,
  });

  final String label;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              icon,
              size: iconSize,
              color: AppColors.textSecondary.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: MobileReportTheme.chipBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
