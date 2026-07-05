import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllTransactionsReportContent extends ConsumerWidget {
  const AllTransactionsReportContent({super.key});

  static const _exportHeaders = [
    '#',
    'Date',
    'Ref No.',
    'Party Name',
    'Category',
    'Type',
    'Total',
    'Received',
    'Balance',
    'Due Date',
    'Status',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(allTransactionsReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(allTransactionsReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;

        List<List<String>> exportRows() => [
              for (var i = 0; i < rows.length; i++)
                _transactionExportRow(rows[i], i),
            ];

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'All Transactions',
            filename: 'all-transactions',
            headers: _exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'All Transactions',
            headers: _exportHeaders,
            rows: exportRows(),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReportPeriodFilterBar(
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
                        onTap: printReport,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ReportCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 180,
                              child: ReportTransactionTypeFilter(),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ReportSearchField(
                                onChanged: ref
                                    .read(reportFiltersProvider.notifier)
                                    .setSearchQuery,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: reportCardBorder),
                      ReportSyncScrollTable(
                        headerChildren: const [
                          ReportAlignedHeaderCell(label: '#', width: 40),
                          ReportAlignedHeaderCell(label: 'DATE', width: 90),
                          ReportAlignedHeaderCell(label: 'REF NO.', width: 90),
                          Expanded(
                            child: ReportAlignedHeaderCell(label: 'PARTY NAME'),
                          ),
                          ReportAlignedHeaderCell(label: 'CATEGORY', width: 90),
                          ReportAlignedHeaderCell(label: 'TYPE', width: 80),
                          ReportAlignedHeaderCell(
                            label: 'TOTAL',
                            width: 80,
                            alignment: Alignment.centerRight,
                          ),
                          ReportAlignedHeaderCell(
                            label: 'RECEIVED',
                            width: 90,
                            alignment: Alignment.centerRight,
                          ),
                          ReportAlignedHeaderCell(
                            label: 'BALANCE',
                            width: 80,
                            alignment: Alignment.centerRight,
                          ),
                          ReportAlignedHeaderCell(label: 'DUE DATE', width: 90),
                          ReportAlignedHeaderCell(label: 'STATUS', width: 80),
                          ReportAlignedHeaderCell(
                            label: 'PRINT',
                            width: 60,
                            showFilter: false,
                          ),
                        ],
                        rows: [
                          for (var i = 0; i < rows.length; i++)
                            _AllTransactionsRow(row: rows[i], index: i),
                        ],
                        emptyState: const ReportEmptyTableState(
                          message: 'No transactions to display.',
                        ),
                      ),
                      ReportPaginationBar(
                        page: report.meta.page,
                        totalPages: report.meta.totalPages,
                        onPrevious: report.meta.page > 1
                            ? () => ref
                                  .read(allTransactionsReportProvider.notifier)
                                  .goToPage(report.meta.page - 1)
                            : null,
                        onNext: report.meta.page < report.meta.totalPages
                            ? () => ref
                                  .read(allTransactionsReportProvider.notifier)
                                  .goToPage(report.meta.page + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<String> _transactionExportRow(ReportTransactionRow row, int index) {
  return [
    '${index + 1}',
    formatReportDate(row.date),
    row.refNo,
    row.partyName,
    row.category,
    row.type,
    formatReportCurrencyCompact(row.total),
    if (row.received > 0) formatReportCurrencyCompact(row.received) else '',
    if (row.balance > 0) formatReportCurrencyCompact(row.balance) else '',
    if (row.dueDate != null) formatReportDate(row.dueDate!) else '',
    row.status,
  ];
}

class _AllTransactionsRow extends StatelessWidget {
  const _AllTransactionsRow({required this.row, required this.index});

  final ReportTransactionRow row;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ReportAlignedRowStrip(
      index: index,
      child: ReportAlignedDataRow(
        cells: [
          ReportAlignedCell.fixed(40, child: Text('${index + 1}')),
          ReportAlignedCell.fixed(
            90,
            child: Text(formatReportDate(row.date)),
          ),
          ReportAlignedCell.fixed(90, child: Text(row.refNo)),
          ReportAlignedCell.flex(child: Text(row.partyName)),
          ReportAlignedCell.fixed(90, child: Text(row.category)),
          ReportAlignedCell.fixed(80, child: Text(row.type)),
          ReportAlignedCell.fixed(
            80,
            alignment: Alignment.centerRight,
            child: Text(formatReportCurrencyCompact(row.total)),
          ),
          ReportAlignedCell.fixed(
            90,
            alignment: Alignment.centerRight,
            child: Text(
              row.received > 0
                  ? formatReportCurrencyCompact(row.received)
                  : '',
            ),
          ),
          ReportAlignedCell.fixed(
            80,
            alignment: Alignment.centerRight,
            child: Text(
              row.balance > 0
                  ? formatReportCurrencyCompact(row.balance)
                  : '',
            ),
          ),
          ReportAlignedCell.fixed(
            90,
            child: Text(
              row.dueDate != null ? formatReportDate(row.dueDate!) : '',
            ),
          ),
          ReportAlignedCell.fixed(80, child: Text(row.status)),
          ReportAlignedCell.fixed(
            60,
            child: IconButton(
              onPressed: () => reportPrintRow(
                context: context,
                title: 'Transaction ${row.refNo}',
                headers: AllTransactionsReportContent._exportHeaders,
                row: _transactionExportRow(row, index),
              ),
              icon: const Icon(Icons.print_outlined, size: 18),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        ],
      ),
    );
  }
}
