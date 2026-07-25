import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReportPeriodFilterBar extends ConsumerStatefulWidget {
  const ReportPeriodFilterBar({
    this.showFirmFilter = true,
    this.trailing,
    super.key,
  });

  final bool showFirmFilter;
  final Widget? trailing;

  @override
  ConsumerState<ReportPeriodFilterBar> createState() =>
      _ReportPeriodFilterBarState();
}

class _ReportPeriodFilterBarState extends ConsumerState<ReportPeriodFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();

  static const _periodOptions = [
    'All Time',
    'Today',
    'Yesterday',
    'This Week',
    'Last Week',
    'This Month',
    'Last Month',
    'This Quarter',
    'This Year',
    'Custom',
  ];

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final dateRange = filters.effectiveDateRange;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SaleFilterDropdown(
          label: filters.periodLabel,
          options: _periodOptions,
          selected: filters.periodLabel,
          onSelected: (value) {
            notifier.setPeriod(ReportPeriod.fromLabel(value));
          },
        ),
        if (filters.period == ReportPeriod.custom) ...[
          const Text(
            'Between',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          SaleDateRangePickerAnchor(
            key: _datePickerKey,
            initialRange: dateRange,
            onRangeSelected: notifier.setCustomDateRange,
            child: SaleFilterChip(
              label: formatSaleDateRangeLabel(dateRange),
              onTap: () => _datePickerKey.currentState?.toggle(),
            ),
          ),
        ],
        if (widget.showFirmFilter)
          Tooltip(
            message: 'Multi-firm filtering is not available.',
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.55,
                child: SaleFilterDropdown(
                  label: 'ALL FIRMS',
                  options: const ['ALL FIRMS'],
                  selected: 'ALL FIRMS',
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }
}

/// Chip-style date range picker connected to [reportFiltersProvider].
class ReportDateRangeChipFilter extends ConsumerStatefulWidget {
  const ReportDateRangeChipFilter({
    this.prefixLabel = 'Between',
    super.key,
  });

  final String prefixLabel;

  @override
  ConsumerState<ReportDateRangeChipFilter> createState() =>
      _ReportDateRangeChipFilterState();
}

class _ReportDateRangeChipFilterState
    extends ConsumerState<ReportDateRangeChipFilter> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final dateRange = filters.effectiveDateRange;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          widget.prefixLabel,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        SaleDateRangePickerAnchor(
          key: _datePickerKey,
          initialRange: dateRange,
          onRangeSelected: notifier.setCustomDateRange,
          child: SaleFilterChip(
            label: formatSaleDateRangeLabel(dateRange),
            onTap: () => _datePickerKey.currentState?.toggle(),
          ),
        ),
      ],
    );
  }
}

/// From/To date range picker connected to [reportFiltersProvider].
class ReportFromToDateFilter extends ConsumerStatefulWidget {
  const ReportFromToDateFilter({
    this.betweenLabel = 'Between',
    this.fromLabel = 'From',
    this.toLabel = 'To',
    super.key,
  });

  final String betweenLabel;
  final String fromLabel;
  final String toLabel;

  @override
  ConsumerState<ReportFromToDateFilter> createState() =>
      _ReportFromToDateFilterState();
}

class _ReportFromToDateFilterState
    extends ConsumerState<ReportFromToDateFilter> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final dateRange = filters.effectiveDateRange;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.betweenLabel.isNotEmpty) ...[
          Text(
            widget.betweenLabel,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        const Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          _dateFormat.format(dateRange.start),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Text(
          'to',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SaleDateRangePickerAnchor(
          key: _datePickerKey,
          initialRange: dateRange,
          onRangeSelected: notifier.setCustomDateRange,
          child: InkWell(
            onTap: () => _datePickerKey.currentState?.toggle(),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _dateFormat.format(dateRange.end),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReportDateRangeBar extends ConsumerStatefulWidget {
  const ReportDateRangeBar({
    this.fromLabel = 'From:',
    this.toLabel = 'To:',
    this.trailing,
    super.key,
  });

  final String fromLabel;
  final String toLabel;
  final Widget? trailing;

  @override
  ConsumerState<ReportDateRangeBar> createState() => _ReportDateRangeBarState();
}

class _ReportDateRangeBarState extends ConsumerState<ReportDateRangeBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final dateRange = filters.effectiveDateRange;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: reportCardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.fromLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(dateRange.start),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      widget.toLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    SaleDateRangePickerAnchor(
                      key: _datePickerKey,
                      initialRange: dateRange,
                      onRangeSelected: notifier.setCustomDateRange,
                      child: SaleFilterChip(
                        label: dateFormat.format(dateRange.end),
                        onTap: () => _datePickerKey.currentState?.toggle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          widget.trailing!,
        ],
      ],
    );
  }
}

class ReportMoneySummaryFooter extends StatelessWidget {
  const ReportMoneySummaryFooter({
    required this.items,
    super.key,
  });

  final List<ReportMoneySummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: reportCardBorder)),
      ),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.sm,
        children: items.map((item) => _FooterItem(item: item)).toList(),
      ),
    );
  }
}

class ReportMoneySummaryItem {
  const ReportMoneySummaryItem({
    required this.label,
    required this.amount,
    this.color,
    this.bold = false,
  });

  final String label;
  final String amount;
  final Color? color;
  final bool bold;
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({required this.item});

  final ReportMoneySummaryItem item;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: item.bold ? FontWeight.w700 : FontWeight.w500,
      color: item.color ?? AppColors.textPrimary,
    );

    return Text('${item.label}: ${item.amount}', style: style);
  }
}
