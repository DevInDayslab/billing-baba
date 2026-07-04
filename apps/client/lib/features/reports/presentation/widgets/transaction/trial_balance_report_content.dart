import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_data_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TrialBalanceReportContent extends ConsumerStatefulWidget {
  const TrialBalanceReportContent({super.key});

  @override
  ConsumerState<TrialBalanceReportContent> createState() =>
      _TrialBalanceReportContentState();
}

class _TrialBalanceReportContentState
    extends ConsumerState<TrialBalanceReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  String _period = 'Custom';
  bool _showWorkingTrialBalance = false;
  bool _showZeroBalances = false;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(2026, 4),
    end: DateTime(2026, 7, 3),
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final allRows = ref.watch(reportTrialBalanceProvider);
    final rows = _showZeroBalances
        ? allRows
        : allRows
            .where((row) => row.debit > 0 || row.credit > 0)
            .toList();
    final totalDebit =
        rows.fold<double>(0, (sum, row) => sum + row.debit);
    final totalCredit =
        rows.fold<double>(0, (sum, row) => sum + row.credit);

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Text(
                  'Trial Balance Report',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A237E),
                  ),
                ),
                Spacer(),
                ReportPdfChip(),
                SizedBox(width: AppSpacing.sm),
                ReportXlsChip(),
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
                  ReportSyncScrollTable(
                    minWidth: 640,
                    headerChildren: [
                      const Expanded(
                        child: ReportAlignedHeaderCell(label: 'ACCOUNT'),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'CLOSING BALANCE',
                              style: reportTableHeaderStyle,
                              textAlign: TextAlign.center,
                            ),
                            Row(
                              children: const [
                                Expanded(
                                  child: ReportAlignedHeaderCell(
                                    label: 'DEBIT',
                                    alignment: Alignment.centerRight,
                                  ),
                                ),
                                Expanded(
                                  child: ReportAlignedHeaderCell(
                                    label: 'CREDIT',
                                    alignment: Alignment.centerRight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    rows: [
                      for (var i = 0; i < rows.length; i++)
                        _TrialBalanceRow(row: rows[i], index: i),
                    ],
                    emptyState: const ReportEmptyTableState(
                      message: 'No data available for the selected period.',
                      minHeight: 180,
                    ),
                  ),
                  Container(
                    color: const Color(0xFFE8F1FB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
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
                                  totalDebit > 0
                                      ? formatReportCurrency(totalDebit)
                                      : '--',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: reportActiveBlue,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  totalCredit > 0
                                      ? formatReportCurrency(totalCredit)
                                      : '--',
                                  style: const TextStyle(
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

class _TrialBalanceRow extends StatelessWidget {
  const _TrialBalanceRow({required this.row, required this.index});

  final ReportTrialBalanceRow row;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedRowStrip(
      index: index,
      child: ReportAlignedDataRow(
        cells: [
          ReportAlignedCell.flex(child: Text(row.accountName)),
          ReportAlignedCell.flex(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.debit > 0 ? formatReportCurrency(row.debit) : '',
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    row.credit > 0 ? formatReportCurrency(row.credit) : '',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
