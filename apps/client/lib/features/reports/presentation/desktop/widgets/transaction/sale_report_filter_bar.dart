import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);

class SaleReportFilterBar extends ConsumerStatefulWidget {
  const SaleReportFilterBar({super.key});

  @override
  ConsumerState<SaleReportFilterBar> createState() =>
      _SaleReportFilterBarState();
}

class _SaleReportFilterBarState extends ConsumerState<SaleReportFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  final _periodDropdownKey = GlobalKey<SaleFilterDropdownState>();

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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _cardBorder),
      ),
      child: Padding(
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
              key: _periodDropdownKey,
              label: filters.periodLabel,
              options: _periodOptions,
              selected: filters.periodLabel,
              onSelected: (value) {
                notifier.setPeriod(ReportPeriod.fromLabel(value));
              },
            ),
            ReportDateRangePickerAnchor(
              anchorKey: _datePickerKey,
              initialRange: dateRange,
              onRangeSelected: notifier.setCustomDateRange,
              child: SaleFilterChip(
                label: formatSaleDateRangeLabel(dateRange),
                leadingIcon: Icons.calendar_today_outlined,
                onTap: () {
                  _periodDropdownKey.currentState?.closeMenu();
                  _datePickerKey.currentState?.toggle();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
