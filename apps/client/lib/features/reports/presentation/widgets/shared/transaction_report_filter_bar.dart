import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionReportFilterBar extends ConsumerStatefulWidget {
  const TransactionReportFilterBar({
    this.showFirmFilter = false,
    super.key,
  });

  final bool showFirmFilter;

  @override
  ConsumerState<TransactionReportFilterBar> createState() =>
      _TransactionReportFilterBarState();
}

class _TransactionReportFilterBarState
    extends ConsumerState<TransactionReportFilterBar> {
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
    final dateRange = filters.customDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now(),
        );

    return ReportCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Filter by :',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SaleFilterDropdown(
            label: filters.periodLabel,
            options: _periodOptions,
            selected: filters.periodLabel,
            onSelected: (value) {
              notifier.setPeriod(ReportPeriod.fromLabel(value));
            },
          ),
          if (filters.period == ReportPeriod.custom)
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
      ),
    );
  }
}
