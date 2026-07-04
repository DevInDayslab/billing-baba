import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashFlowReportContent extends ConsumerStatefulWidget {
  const CashFlowReportContent({super.key});

  @override
  ConsumerState<CashFlowReportContent> createState() =>
      _CashFlowReportContentState();
}

class _CashFlowReportContentState extends ConsumerState<CashFlowReportContent> {
  bool _showZeroAmount = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(cashFlowReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(cashFlowReportProvider.notifier).refresh(),
      data: (report) {
        final cashRows = report.rows.where((row) {
          if (_showZeroAmount) return true;
          return row.moneyIn > 0 || row.moneyOut > 0;
        }).toList();

        final opening = report.openingBalance;
        final closing = report.closingBalance;
        final totalCashIn = report.totalMoneyIn;
        final totalCashOut = report.totalMoneyOut;

        var runningBalance = opening;
        final rowsWithBalance = cashRows.map((row) {
          runningBalance += row.moneyIn - row.moneyOut;
          return (row: row, balance: runningBalance);
        }).toList();

        void exportCsv() {
          ReportExportService.exportAndNotify(
            context: context,
            title: 'Cash Flow',
            filename: 'cash-flow',
            headers: const [
              'Date',
              'Ref No',
              'Name',
              'Category',
              'Type',
              'Cash In',
              'Cash Out',
              'Running Balance',
            ],
            rows: [
              for (final entry in rowsWithBalance)
                [
                  formatReportDate(entry.row.date),
                  entry.row.refNo,
                  entry.row.partyName,
                  entry.row.category,
                  entry.row.type,
                  entry.row.moneyIn > 0
                      ? formatReportCurrencyCompact(entry.row.moneyIn)
                      : '',
                  entry.row.moneyOut > 0
                      ? formatReportCurrencyCompact(entry.row.moneyOut)
                      : '',
                  formatReportCurrencyCompact(entry.balance),
                ],
            ],
          );
        }

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
                child: ReportPeriodFilterBar(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReportTextActionButton(
                        label: 'Excel Report',
                        icon: Icons.table_chart_outlined,
                        onTap: exportCsv,
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: () => ReportExportService.showPrintPreview(
                          context: context,
                          title: 'Cash Flow',
                          content: ReportExportService.toCsv(
                            headers: const [
                              'Date',
                              'Ref No',
                              'Name',
                              'Category',
                              'Type',
                              'Cash In',
                              'Cash Out',
                              'Running Balance',
                            ],
                            rows: [
                              for (final entry in rowsWithBalance)
                                [
                                  formatReportDate(entry.row.date),
                                  entry.row.refNo,
                                  entry.row.partyName,
                                  entry.row.category,
                                  entry.row.type,
                                  entry.row.moneyIn > 0
                                      ? formatReportCurrencyCompact(
                                          entry.row.moneyIn,
                                        )
                                      : '',
                                  entry.row.moneyOut > 0
                                      ? formatReportCurrencyCompact(
                                          entry.row.moneyOut,
                                        )
                                      : '',
                                  formatReportCurrencyCompact(entry.balance),
                                ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      'Opening Cash-in Hand: ${formatReportCurrency(opening)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: reportTeal,
                      ),
                    ),
                    const Spacer(),
                    Checkbox(
                      value: _showZeroAmount,
                      onChanged: (v) =>
                          setState(() => _showZeroAmount = v ?? false),
                      visualDensity: VisualDensity.compact,
                    ),
                    const Text(
                      'Show zero amount transaction',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: ReportSearchField(
                            onChanged: ref
                                .read(reportFiltersProvider.notifier)
                                .setSearchQuery,
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportSyncScrollTable(
                            minWidth: 900,
                            headerChildren: const [
                              ReportAlignedHeaderCell(label: 'DATE', width: 90),
                              ReportAlignedHeaderCell(
                                label: 'REF NO.',
                                width: 90,
                              ),
                              Expanded(
                                child: ReportAlignedHeaderCell(label: 'NAME'),
                              ),
                              ReportAlignedHeaderCell(
                                label: 'CATEGORY',
                                width: 90,
                              ),
                              ReportAlignedHeaderCell(label: 'TYPE', width: 80),
                              ReportAlignedHeaderCell(
                                label: 'CASH IN',
                                width: 90,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'CASH OUT',
                                width: 90,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'RUNNING BAL.',
                                width: 100,
                                alignment: Alignment.centerRight,
                              ),
                              ReportAlignedHeaderCell(
                                label: 'PRINT/SHARE',
                                width: 100,
                                showFilter: false,
                              ),
                            ],
                            rows: [
                              for (var i = 0; i < rowsWithBalance.length; i++)
                                _CashFlowRow(
                                  row: rowsWithBalance[i].row,
                                  runningBalance: rowsWithBalance[i].balance,
                                  index: i,
                                ),
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
                        ReportMoneySummaryFooter(
                          items: [
                            ReportMoneySummaryItem(
                              label: 'Total Cash-in',
                              amount: formatReportCurrency(totalCashIn),
                              color: reportTeal,
                            ),
                            ReportMoneySummaryItem(
                              label: 'Total Cash-out',
                              amount: formatReportCurrency(totalCashOut),
                              color: reportAddRed,
                            ),
                            ReportMoneySummaryItem(
                              label: 'Closing Cash-in Hand',
                              amount: formatReportCurrency(closing),
                              color: reportTeal,
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

class _CashFlowRow extends StatelessWidget {
  const _CashFlowRow({
    required this.row,
    required this.runningBalance,
    required this.index,
  });

  final ReportTransactionRow row;
  final double runningBalance;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedRowStrip(
      index: index,
      child: ReportAlignedDataRow(
        cells: [
          ReportAlignedCell.fixed(
            90,
            child: Text(formatReportDate(row.date)),
          ),
          ReportAlignedCell.fixed(90, child: Text(row.refNo)),
          ReportAlignedCell.flex(child: Text(row.partyName)),
          ReportAlignedCell.fixed(90, child: Text(row.category)),
          ReportAlignedCell.fixed(80, child: Text(row.type)),
          ReportAlignedCell.fixed(
            90,
            alignment: Alignment.centerRight,
            child: Text(
              row.moneyIn > 0
                  ? formatReportCurrencyCompact(row.moneyIn)
                  : '',
            ),
          ),
          ReportAlignedCell.fixed(
            90,
            alignment: Alignment.centerRight,
            child: Text(
              row.moneyOut > 0
                  ? formatReportCurrencyCompact(row.moneyOut)
                  : '',
            ),
          ),
          ReportAlignedCell.fixed(
            100,
            alignment: Alignment.centerRight,
            child: Text(formatReportCurrencyCompact(runningBalance)),
          ),
          ReportAlignedCell.fixed(
            100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.print_outlined, size: 18),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, size: 18),
                  color: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
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
