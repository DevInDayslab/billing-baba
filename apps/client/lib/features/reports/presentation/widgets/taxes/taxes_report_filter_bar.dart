import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaxesReportFilterBar extends StatefulWidget {
  const TaxesReportFilterBar({
    this.onExportExcel,
    this.onPrint,
    super.key,
  });

  final VoidCallback? onExportExcel;
  final VoidCallback? onPrint;

  @override
  State<TaxesReportFilterBar> createState() => _TaxesReportFilterBarState();
}

class _TaxesReportFilterBarState extends State<TaxesReportFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _firm = 'ALL FIRMS';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7),
    end: DateTime(2026, 7, 3),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return ReportCard(
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
                onRangeSelected: (range) => setState(() => _dateRange = range),
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
    );
  }
}

class TaxInvoiceReportFilterBar extends StatefulWidget {
  const TaxInvoiceReportFilterBar({
    this.onExportExcel,
    this.onPrint,
    super.key,
  });

  final VoidCallback? onExportExcel;
  final VoidCallback? onPrint;

  @override
  State<TaxInvoiceReportFilterBar> createState() =>
      _TaxInvoiceReportFilterBarState();
}

class _TaxInvoiceReportFilterBarState extends State<TaxInvoiceReportFilterBar> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _firm = 'ALL FIRMS';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7),
    end: DateTime(2026, 7, 3),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: reportTableHeaderBg,
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
            'Between',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
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
                onRangeSelected: (range) => setState(() => _dateRange = range),
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
            label: _firm,
            options: const ['ALL FIRMS', 'Firm A', 'Firm B'],
            selected: _firm,
            onSelected: (value) => setState(() => _firm = value),
          ),
          ReportTextActionButton(
            label: 'Excel Report',
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
    );
  }
}
