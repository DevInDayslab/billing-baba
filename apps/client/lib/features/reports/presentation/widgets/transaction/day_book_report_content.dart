import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayBookReportContent extends StatefulWidget {
  const DayBookReportContent({super.key});

  @override
  State<DayBookReportContent> createState() => _DayBookReportContentState();
}

class _DayBookReportContentState extends State<DayBookReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  DateTime _selectedDate = DateTime(2026, 7, 3);

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SaleDateRangePickerAnchor(
                  key: _datePickerKey,
                  initialRange: DateTimeRange(
                    start: _selectedDate,
                    end: _selectedDate,
                  ),
                  onRangeSelected: (range) =>
                      setState(() => _selectedDate = range.start),
                  child: SaleFilterChip(
                    label: _dateFormat.format(_selectedDate),
                    onTap: () => _datePickerKey.currentState?.toggle(),
                  ),
                ),
                const Spacer(),
                const ReportTextActionButton(
                  label: 'Excel Report',
                  icon: Icons.table_chart_outlined,
                ),
                const ReportTextActionButton(
                  label: 'Print',
                  icon: Icons.print_outlined,
                ),
              ],
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: ReportCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: ReportSearchField(
                        hintText: 'Search transactions...',
                      ),
                    ),
                    Divider(height: 1, color: reportCardBorder),
                    ReportTableHeaderRow(
                      children: [
                        Expanded(
                          child: ReportTableHeaderCell(label: 'NAME'),
                        ),
                        ReportTableHeaderCell(label: 'REF NO.', width: 100),
                        ReportTableHeaderCell(label: 'TYPE', width: 90),
                        ReportTableHeaderCell(
                          label: 'TOTAL',
                          width: 90,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'MONEY IN',
                          width: 100,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'MONEY OUT',
                          width: 100,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'PRINT/ SHARE',
                          width: 110,
                          showFilter: false,
                        ),
                      ],
                    ),
                    Divider(height: 1, color: reportCardBorder),
                    Expanded(
                      child: Center(
                        child: Text(
                          'No transactions to show',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    ReportMoneySummaryFooter(
                      items: [
                        ReportMoneySummaryItem(
                          label: 'Total Money-In',
                          amount: '₹0.00',
                          color: reportTeal,
                        ),
                        ReportMoneySummaryItem(
                          label: 'Total Money-Out',
                          amount: '₹0.00',
                          color: reportAddRed,
                        ),
                        ReportMoneySummaryItem(
                          label: 'Total Money In - Total Money Out',
                          amount: '₹0.00',
                          bold: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
