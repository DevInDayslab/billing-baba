import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrialBalanceReportContent extends StatefulWidget {
  const TrialBalanceReportContent({super.key});

  @override
  State<TrialBalanceReportContent> createState() =>
      _TrialBalanceReportContentState();
}

class _TrialBalanceReportContentState extends State<TrialBalanceReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _period = 'Custom';
  bool _showWorkingTrialBalance = false;
  bool _showZeroBalances = false;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 4, 1),
    end: DateTime(2026, 7, 3),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'Trial Balance Report',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                const ReportPdfChip(),
                const SizedBox(width: AppSpacing.sm),
                const ReportXlsChip(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Period :',
                        style: TextStyle(fontSize: 13),
                      ),
                      SaleFilterDropdown(
                        label: _period,
                        options: const [
                          'This Month',
                          'This Year',
                          'Custom',
                        ],
                        selected: _period,
                        onSelected: (v) => setState(() => _period = v),
                      ),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      Text(_dateFormat.format(_dateRange.start)),
                      const Text(
                        'To',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SaleDateRangePickerAnchor(
                        key: _datePickerKey,
                        initialRange: _dateRange,
                        onRangeSelected: (range) =>
                            setState(() => _dateRange = range),
                        child: SaleFilterChip(
                          label: _dateFormat.format(_dateRange.end),
                          onTap: () => _datePickerKey.currentState?.toggle(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Checkbox(
                        value: _showWorkingTrialBalance,
                        onChanged: (v) => setState(
                          () => _showWorkingTrialBalance = v ?? false,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Show working trial balance',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Checkbox(
                        value: _showZeroBalances,
                        onChanged: (v) =>
                            setState(() => _showZeroBalances = v ?? false),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Show 0 balances account',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.expand_less, size: 18),
                    label: const Text('Collapse all accounts'),
                    style: TextButton.styleFrom(
                      foregroundColor: reportActiveBlue,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ReportCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: reportTableHeaderBg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ACCOUNT',
                            style: reportTableHeaderStyle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'CLOSING BALANCE',
                                style: reportTableHeaderStyle,
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'DEBIT',
                                      style: reportTableHeaderStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'CREDIT',
                                      style: reportTableHeaderStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: reportCardBorder),
                  const ReportEmptyTableState(
                    message: 'No data available for the selected period.',
                    minHeight: 180,
                  ),
                  Container(
                    color: const Color(0xFFE8F1FB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: reportActiveBlue,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '--',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: reportActiveBlue,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '--',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: reportActiveBlue,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
