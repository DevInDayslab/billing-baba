import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';

const _cardBorder = Color(0xFFE0E0E0);

class SaleReportFilterBar extends StatefulWidget {
  const SaleReportFilterBar({super.key});

  @override
  State<SaleReportFilterBar> createState() => _SaleReportFilterBarState();
}

class _SaleReportFilterBarState extends State<SaleReportFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();

  String _timeRange = 'This Month';
  String _firm = 'All Firms';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2025, 9, 1),
    end: DateTime(2025, 9, 30),
  );

  @override
  Widget build(BuildContext context) {
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
            SaleFilterDropdown(
              label: _firm,
              options: const ['All Firms', 'Firm A', 'Firm B'],
              selected: _firm,
              onSelected: (value) => setState(() => _firm = value),
            ),
          ],
        ),
      ),
    );
  }
}
