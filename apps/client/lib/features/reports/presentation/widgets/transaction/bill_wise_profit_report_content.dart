import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BillWiseProfitReportContent extends ConsumerWidget {
  const BillWiseProfitReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(billWiseProfitReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(billWiseProfitReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalSale =
            rows.fold<double>(0, (sum, row) => sum + row.saleAmount);
        final totalProfit =
            rows.fold<double>(0, (sum, row) => sum + row.profit);

        void exportCsv() {
          ReportExportService.exportAndNotify(
            context: context,
            title: 'Bill Wise Profit',
            filename: 'bill-wise-profit',
            headers: const [
              'Date',
              'Invoice No',
              'Party',
              'Total Sale Amount',
              'Profit/Loss',
            ],
            rows: [
              for (final row in rows)
                [
                  formatReportDate(row.date),
                  row.invoiceNo,
                  row.partyName,
                  formatReportCurrency(row.saleAmount),
                  formatReportCurrency(row.profit),
                ],
            ],
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReportDateRangeBar(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReportIconActionButton(
                        icon: Icons.table_chart_outlined,
                        tooltip: 'Excel',
                        onTap: exportCsv,
                      ),
                      ReportIconActionButton(
                        icon: Icons.print_outlined,
                        tooltip: 'Print',
                        onTap: () => ReportExportService.showPrintPreview(
                          context: context,
                          title: 'Bill Wise Profit',
                          content: ReportExportService.toCsv(
                            headers: const [
                              'Date',
                              'Invoice No',
                              'Party',
                              'Total Sale Amount',
                              'Profit/Loss',
                            ],
                            rows: [
                              for (final row in rows)
                                [
                                  formatReportDate(row.date),
                                  row.invoiceNo,
                                  row.partyName,
                                  formatReportCurrency(row.saleAmount),
                                  formatReportCurrency(row.profit),
                                ],
                            ],
                          ),
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
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          'PROFIT ON SALE INVOICES',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'FILTERS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextField(
                                onChanged: ref
                                    .read(reportFiltersProvider.notifier)
                                    .setSearchQuery,
                                decoration: InputDecoration(
                                  hintText: 'Party filter',
                                  hintStyle: const TextStyle(fontSize: 13),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    borderSide: const BorderSide(
                                      color: reportCardBorder,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    borderSide: const BorderSide(
                                      color: reportCardBorder,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(height: 1, color: reportCardBorder),
                      ReportSyncScrollTable(
                        minWidth: 800,
                        headerChildren: const [
                          ReportAlignedHeaderCell(label: 'DATE', width: 90),
                          ReportAlignedHeaderCell(
                            label: 'INVOICE NO',
                            width: 110,
                          ),
                          Expanded(
                            child: ReportAlignedHeaderCell(label: 'PARTY'),
                          ),
                          ReportAlignedHeaderCell(
                            label: 'TOTAL SALE AMOUNT',
                            width: 140,
                            alignment: Alignment.centerRight,
                          ),
                          ReportAlignedHeaderCell(
                            label: 'PROFIT (+) / LOSS (-)',
                            width: 140,
                            alignment: Alignment.centerRight,
                          ),
                          ReportAlignedHeaderCell(
                            label: 'DETAILS',
                            width: 80,
                            showFilter: false,
                          ),
                        ],
                        rows: [
                          for (var i = 0; i < rows.length; i++)
                            _BillWiseProfitRow(row: rows[i], index: i),
                        ],
                        emptyState: const SizedBox(
                          height: 160,
                          child: Center(
                            child: Text(
                              'No data for selected period',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: reportCardBorder),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Summary',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Text(
                                  'Total Sale Amount: '
                                  '${formatReportCurrency(totalSale)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                Text(
                                  'Total Profit(+)/Loss(-): '
                                  '${formatReportCurrency(totalProfit)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: reportTeal,
                                    fontWeight: FontWeight.w600,
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
                ReportPaginationBar(
                  page: report.meta.page,
                  totalPages: report.meta.totalPages,
                  onPrevious: report.meta.page > 1
                      ? () => ref
                            .read(billWiseProfitReportProvider.notifier)
                            .goToPage(report.meta.page - 1)
                      : null,
                  onNext: report.meta.page < report.meta.totalPages
                      ? () => ref
                            .read(billWiseProfitReportProvider.notifier)
                            .goToPage(report.meta.page + 1)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BillWiseProfitRow extends StatelessWidget {
  const _BillWiseProfitRow({required this.row, required this.index});

  final ReportBillWiseProfitRow row;
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
          ReportAlignedCell.fixed(110, child: Text(row.invoiceNo)),
          ReportAlignedCell.flex(child: Text(row.partyName)),
          ReportAlignedCell.fixed(
            140,
            alignment: Alignment.centerRight,
            child: Text(formatReportCurrency(row.saleAmount)),
          ),
          ReportAlignedCell.fixed(
            140,
            alignment: Alignment.centerRight,
            child: Text(
              formatReportCurrency(row.profit),
              style: TextStyle(
                color: row.profit >= 0 ? reportTeal : reportAddRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ReportAlignedCell.fixed(
            80,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.visibility_outlined, size: 18),
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
