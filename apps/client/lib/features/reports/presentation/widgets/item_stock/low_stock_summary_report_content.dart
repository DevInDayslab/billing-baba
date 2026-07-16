import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LowStockSummaryReportContent extends ConsumerWidget {
  const LowStockSummaryReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final reportAsync = ref.watch(lowStockReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(lowStockReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final filterNotifier = ref.read(reportFiltersProvider.notifier);

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Low Stock Summary',
            filename: 'low-stock-summary',
            headers: const [
              'Item Name',
              'Minimum Stock Qty',
              'Stock Qty',
              'Stock Value',
            ],
            rows: [
              for (final row in rows)
                [
                  row.itemName,
                  row.minStock.toStringAsFixed(0),
                  row.currentStock.toStringAsFixed(0),
                  '—',
                ],
            ],
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Low Stock Summary',
            headers: const [
              'Item Name',
              'Minimum Stock Qty',
              'Stock Qty',
              'Stock Value',
            ],
            rows: [
              for (final row in rows)
                [
                  row.itemName,
                  row.minStock.toStringAsFixed(0),
                  row.currentStock.toStringAsFixed(0),
                  '—',
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
                                'LOW STOCK SUMMARY',
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
                        Expanded(
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
                                          label: 'MINIMUM STOCK QTY',
                                          width: 150,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'STOCK QTY',
                                          width: 110,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'STOCK VALUE',
                                          width: 120,
                                          alignment: Alignment.centerRight,
                                        ),
                                      ],
                                      rows: [],
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'No low stock items found based on the selected filters.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SingleChildScrollView(
                                  child: ReportSyncScrollTable(
                                    headerChildren: const [
                                      Expanded(
                                        child: ReportAlignedHeaderCell(
                                          label: 'ITEM NAME',
                                        ),
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'MINIMUM STOCK QTY',
                                        width: 150,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'STOCK QTY',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'STOCK VALUE',
                                        width: 120,
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
                                                150,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  rows[i].minStock
                                                      .toStringAsFixed(0),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  rows[i].currentStock
                                                      .toStringAsFixed(0),
                                                ),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                120,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('—'),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                        ),
                        ReportPaginationBar(
                          page: report.meta.page,
                          totalPages: report.meta.totalPages,
                          onPrevious: report.meta.page > 1
                              ? () => ref
                                    .read(lowStockReportProvider.notifier)
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(lowStockReportProvider.notifier)
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
