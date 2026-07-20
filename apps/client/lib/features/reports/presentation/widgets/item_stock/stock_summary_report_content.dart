import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
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

class StockSummaryReportContent extends ConsumerWidget {
  const StockSummaryReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final reportAsync = ref.watch(stockSummaryReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(stockSummaryReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalStockValue = report.totalStockValue;
        final filterNotifier = ref.read(reportFiltersProvider.notifier);

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Stock Summary',
            filename: 'stock-summary',
            headers: const [
              'Item Name',
              'Sale Price',
              'Purchase Price',
              'Stock Qty',
              'Stock Value',
            ],
            rows: [
              for (final row in rows)
                [
                  row.itemName,
                  formatReportCurrency(row.salePrice),
                  formatReportCurrency(row.purchasePrice),
                  row.stockQty.toStringAsFixed(0),
                  formatReportCurrency(row.stockValue),
                ],
            ],
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Stock Summary',
            headers: const [
              'Item Name',
              'Sale Price',
              'Purchase Price',
              'Stock Qty',
              'Stock Value',
            ],
            rows: [
              for (final row in rows)
                [
                  row.itemName,
                  formatReportCurrency(row.salePrice),
                  formatReportCurrency(row.purchasePrice),
                  row.stockQty.toStringAsFixed(0),
                  formatReportCurrency(row.stockValue),
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
                child: ReportCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                        const ReportCategoryFilter(),
                        const ReportGodownFilter(),
                        const ReportDisabledDateFilter(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: filters.inStockOnly,
                              onChanged: (value) =>
                                  filterNotifier.setInStockOnly(
                                    value ?? false,
                                  ),
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text(
                              'Show items in stock',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        ReportTextActionButton(
                          label: 'Excel',
                          icon: Icons.table_chart_outlined,
                          onTap: exportExcel,
                        ),
                        ReportTextActionButton(
                          label: 'Print',
                          icon: Icons.print_outlined,
                          onTap: exportPrint,
                        ),
                      ],
                    ),
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'STOCK SUMMARY',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 240,
                                child: ReportSearchField(
                                  hintText: 'Search items...',
                                  onChanged: filterNotifier.setSearchQuery,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportTableArea(
                            child: rows.isEmpty
                              ? const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ReportSyncScrollTable(
                                      headerChildren: [
                                        Expanded(
                                          child: ReportAlignedHeaderCell(
                                            label: 'ITEM NAME',
                                          ),
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'SALE PRICE',
                                          width: 110,
                                          alignment: Alignment.center,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'PURCHASE PRICE',
                                          width: 130,
                                          alignment: Alignment.center,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'STOCK QTY',
                                          width: 100,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'STOCK VALUE',
                                          width: 110,
                                          alignment: Alignment.centerRight,
                                        ),
                                      ],
                                      rows: [],
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'No stock items to display.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ReportSyncScrollTable(
                                    headerChildren: const [
                                      Expanded(
                                        child: ReportAlignedHeaderCell(
                                          label: 'ITEM NAME',
                                        ),
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'SALE PRICE',
                                        width: 110,
                                        alignment: Alignment.center,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'PURCHASE PRICE',
                                        width: 130,
                                        alignment: Alignment.center,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'STOCK QTY',
                                        width: 100,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'STOCK VALUE',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ],
                                    rows: [
                                      for (var i = 0; i < rows.length; i++)
                                        ReportAlignedRowStrip(
                                          index: i,
                                          child: ReportAlignedDataRow(
                                            cells: [
                                              ReportAlignedCell.flex(
                                                child: Text(rows[i].itemName),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].salePrice,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                130,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].purchasePrice,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                100,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  rows[i].stockQty
                                                      .toStringAsFixed(0),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].stockValue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                        
                          ),
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
                                    text: 'Total Stock Value: ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatReportCurrency(totalStockValue),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: reportTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ReportPaginationBar(
                          page: report.meta.page,
                          totalPages: report.meta.totalPages,
                          onPrevious: report.meta.page > 1
                              ? () => ref
                                    .read(stockSummaryReportProvider.notifier)
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(stockSummaryReportProvider.notifier)
                                    .goToPage(report.meta.page + 1)
                              : null,
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
