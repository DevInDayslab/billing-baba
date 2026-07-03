import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';

class TransactionReportFilterBar extends StatefulWidget {
  const TransactionReportFilterBar({
    this.showFirmFilter = true,
    this.initialTimeRange = 'This Month',
    this.initialFirm = 'All Firms',
    super.key,
  });

  final bool showFirmFilter;
  final String initialTimeRange;
  final String initialFirm;

  @override
  State<TransactionReportFilterBar> createState() =>
      _TransactionReportFilterBarState();
}

class _TransactionReportFilterBarState
    extends State<TransactionReportFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  late String _timeRange;
  late String _firm;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2025, 9, 1),
    end: DateTime(2025, 9, 30),
  );

  @override
  void initState() {
    super.initState();
    _timeRange = widget.initialTimeRange;
    _firm = widget.initialFirm;
  }

  @override
  Widget build(BuildContext context) {
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
            label: _timeRange,
            options: const [
              'All Time',
              'Today',
              'This Week',
              'This Month',
              'This Year',
              'Custom',
            ],
            selected: _timeRange,
            onSelected: (value) => setState(() => _timeRange = value),
          ),
          SaleDateRangePickerAnchor(
            key: _datePickerKey,
            initialRange: _dateRange,
            onRangeSelected: (range) => setState(() => _dateRange = range),
            child: SaleFilterChip(
              label: formatSaleDateRangeLabel(_dateRange),
              onTap: () => _datePickerKey.currentState?.toggle(),
            ),
          ),
          if (widget.showFirmFilter)
            SaleFilterDropdown(
              label: _firm,
              options: const ['All Firms', 'Firm A', 'Firm B'],
              selected: _firm,
              onSelected: (value) => setState(() => _firm = value),
            ),
        ],
      ),
    );
  }
}
