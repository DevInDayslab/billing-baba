import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DayBookReportContent extends ConsumerStatefulWidget {
  const DayBookReportContent({super.key});

  static const _exportHeaders = [
    'Name',
    'Ref No.',
    'Type',
    'Total',
    'Money In',
    'Money Out',
  ];

  @override
  ConsumerState<DayBookReportContent> createState() =>
      _DayBookReportContentState();
}

class _DayBookReportContentState extends ConsumerState<DayBookReportContent> {
  final _datePickerKey = GlobalKey<SaleDateRangePickerAnchorState>();
  late DateTime _selectedDate;

  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(reportFiltersProvider.notifier).setSelectedDate(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(dayBookReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(dayBookReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalMoneyIn = report.totalMoneyIn;
        final totalMoneyOut = report.totalMoneyOut;
        final netTotal = report.netTotal;
        final exportRows = [
          for (final row in rows) _dayBookExportRow(row),
        ];
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
                      onRangeSelected: (range) {
                        setState(() => _selectedDate = range.start);
                        ref
                            .read(reportFiltersProvider.notifier)
                            .setSelectedDate(range.start);
                      },
                      child: SaleFilterChip(
                        label: _dateFormat.format(_selectedDate),
                        onTap: () => _datePickerKey.currentState?.toggle(),
                      ),
                    ),
                    const Spacer(),
                    ReportTextActionButton(
                      label: 'Excel Report',
                      icon: Icons.table_chart_outlined,
                      onTap: () => reportExportTable(
                        context: context,
                        title: 'Day Book',
                        filename: 'day-book',
                        headers: DayBookReportContent._exportHeaders,
                        rows: exportRows,
                      ),
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: () => reportPrintTable(
                        context: context,
                        title: 'Day Book',
                        headers: DayBookReportContent._exportHeaders,
                        rows: exportRows,
                      ),
                    ),
                  ],
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
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: ReportSearchField(
                            hintText: 'Search transactions...',
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportTableArea(
                            child: ReportSyncScrollTable(
                            minWidth: 800,
                            headerChildren: const [
                              Expanded(
                                child: ReportAlignedHeaderCell(label: 'NAME'),
                              ),
                              ReportAlignedHeaderCell(
                                label: 'REF NO.',
                                width: 100,
                              ),
                              ReportAlignedHeaderCell(label: 'TYPE', width: 90),
                              ReportAlignedHeaderCell(
                                label: 'TOTAL',
                                width: 90,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'MONEY IN',
                                width: 100,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'MONEY OUT',
                                width: 100,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'PRINT/ SHARE',
                                width: 110,
                                showFilter: false,
                              ),
                            ],
                            rows: [
                              for (var i = 0; i < rows.length; i++)
                                _DayBookRow(row: rows[i], index: i),
                            ],
                            emptyState: const Center(
                              child: Text(
                                'No transactions to show',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ),
                        ReportMoneySummaryFooter(
                          items: [
                            ReportMoneySummaryItem(
                              label: 'Total Money-In',
                              amount: formatReportCurrency(totalMoneyIn),
                              color: reportTeal,
                            ),
                            ReportMoneySummaryItem(
                              label: 'Total Money-Out',
                              amount: formatReportCurrency(totalMoneyOut),
                              color: reportAddRed,
                            ),
                            ReportMoneySummaryItem(
                              label: 'Total Money In - Total Money Out',
                              amount: formatReportCurrency(netTotal),
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
      },
    );
  }
}

List<String> _dayBookExportRow(ReportTransactionRow row) {
  return [
    row.partyName,
    row.refNo,
    row.type,
    formatReportCurrencyCompact(row.total),
    if (row.moneyIn > 0) formatReportCurrencyCompact(row.moneyIn) else '',
    if (row.moneyOut > 0) formatReportCurrencyCompact(row.moneyOut) else '',
  ];
}

class _DayBookRow extends StatelessWidget {
  const _DayBookRow({required this.row, required this.index});

  final ReportTransactionRow row;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedRowStrip(
      index: index,
      child: ReportAlignedDataRow(
        cells: [
          ReportAlignedCell.flex(child: Text(row.partyName)),
          ReportAlignedCell.fixed(100, child: Text(row.refNo)),
          ReportAlignedCell.fixed(90, child: Text(row.type)),
          ReportAlignedCell.fixed(
            90,
            alignment: Alignment.centerRight,
            child: Text(formatReportCurrencyCompact(row.total)),
          ),
          ReportAlignedCell.fixed(
            100,
            alignment: Alignment.centerRight,
            child: Text(
              row.moneyIn > 0 ? formatReportCurrencyCompact(row.moneyIn) : '',
              style: row.moneyIn > 0
                  ? const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    )
                  : null,
            ),
          ),
          ReportAlignedCell.fixed(
            100,
            alignment: Alignment.centerRight,
            child: Text(
              row.moneyOut > 0 ? formatReportCurrencyCompact(row.moneyOut) : '',
              style: row.moneyOut > 0
                  ? const TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w500,
                    )
                  : null,
            ),
          ),
          ReportAlignedCell.fixed(
            110,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => reportPrintRow(
                    context: context,
                    title: 'Day Book ${row.refNo}',
                    headers: DayBookReportContent._exportHeaders,
                    row: _dayBookExportRow(row),
                  ),
                  icon: const Icon(Icons.print_outlined, size: 18),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const Tooltip(
                  message: 'Share is not available yet.',
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.share_outlined, size: 18),
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
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
