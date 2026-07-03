import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_table_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BankStatementReportContent extends StatefulWidget {
  const BankStatementReportContent({super.key});

  @override
  State<BankStatementReportContent> createState() =>
      _BankStatementReportContentState();
}

class _BankStatementReportContentState
    extends State<BankStatementReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _selectedBank = 'Select bank account';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 7, 1),
    end: DateTime(2026, 7, 31),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

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
                  'Bank Statement',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F1FB),
                    foregroundColor: reportActiveBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Share With Accountant',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const ReportTextActionButton(
                  label: 'Excel',
                  icon: Icons.table_chart_outlined,
                ),
                const ReportTextActionButton(
                  label: 'Print',
                  icon: Icons.print_outlined,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: ReportCard(
              backgroundColor: const Color(0xFFF5F7FA),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bank name',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 200,
                        child: SaleFilterDropdown(
                          label: _selectedBank,
                          options: const [
                            'Select bank account',
                            'HDFC Bank',
                            'ICICI Bank',
                            'SBI',
                          ],
                          selected: _selectedBank,
                          onSelected: (value) =>
                              setState(() => _selectedBank = value),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: ReportCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        'TRANSACTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    ReportTableHeaderRow(
                      children: const [
                        ReportTableHeaderCell(label: 'DATE', width: 110),
                        Expanded(
                          child: ReportTableHeaderCell(label: 'DESCRIPTION'),
                        ),
                        ReportTableHeaderCell(
                          label: 'WITHDRAWAL AMOUNT',
                          width: 150,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'DEPOSIT AMOUNT',
                          width: 130,
                          alignment: Alignment.centerRight,
                        ),
                        ReportTableHeaderCell(
                          label: 'BALANCE AMOUNT',
                          width: 130,
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: reportCardBorder),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(
                              _dateFormat.format(_dateRange.start),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Bank balance forward',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(
                            width: 150,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 130,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: reportTeal,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _currencyFormat.format(0),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: reportCardBorder),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              const TextSpan(
                                text: 'Balance ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: _currencyFormat.format(0),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
