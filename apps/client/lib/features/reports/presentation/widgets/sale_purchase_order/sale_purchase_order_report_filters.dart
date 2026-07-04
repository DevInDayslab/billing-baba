import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalePurchaseOrderReportFilters extends StatefulWidget {
  const SalePurchaseOrderReportFilters({
    this.onExportExcel,
    this.onPrint,
    super.key,
  });

  final VoidCallback? onExportExcel;
  final VoidCallback? onPrint;

  @override
  State<SalePurchaseOrderReportFilters> createState() =>
      _SalePurchaseOrderReportFiltersState();
}

class _SalePurchaseOrderReportFiltersState
    extends State<SalePurchaseOrderReportFilters> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _firm = 'ALL FIRMS';
  String _user = 'ALL USER';
  String _orderType = 'SALE ORDER';
  String _status = 'All Orders';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7),
    end: DateTime(2026, 7, 3),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SaleFilterDropdown(
                label: _firm,
                options: const ['ALL FIRMS', 'Firm A', 'Firm B'],
                selected: _firm,
                onSelected: (value) => setState(() => _firm = value),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'From',
                    style: TextStyle(
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
                    _dateFormat.format(_dateRange.start),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Text(
                    'To',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SaleDateRangePickerAnchor(
                    key: _datePickerKey,
                    initialRange: _dateRange,
                    onRangeSelected: (range) =>
                        setState(() => _dateRange = range),
                    child: InkWell(
                      onTap: () => _datePickerKey.currentState?.toggle(),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
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
                              _dateFormat.format(_dateRange.end),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SaleFilterDropdown(
                label: _user,
                options: const ['ALL USER', 'User A', 'User B'],
                selected: _user,
                onSelected: (value) => setState(() => _user = value),
              ),
              ReportTextActionButton(
                label: 'Excel',
                icon: Icons.table_chart_outlined,
                onTap: widget.onExportExcel,
              ),
              ReportTextActionButton(
                label: 'Print',
                icon: Icons.print_outlined,
                onTap: widget.onPrint,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ReportCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'FILTERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Party filter',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: reportCardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: reportCardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: reportTeal),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    isDense: true,
                  ),
                ),
              ),
              SaleFilterDropdown(
                label: _orderType,
                options: const [
                  'SALE ORDER',
                  'PURCHASE ORDER',
                  'SALE RETURN ORDER',
                  'PURCHASE RETURN ORDER',
                ],
                selected: _orderType,
                onSelected: (value) => setState(() => _orderType = value),
              ),
              SaleFilterDropdown(
                label: _status,
                options: const [
                  'All Orders',
                  'Open',
                  'Closed',
                  'Partial',
                  'Cancelled',
                ],
                selected: _status,
                onSelected: (value) => setState(() => _status = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
