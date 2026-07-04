import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/providers/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LowStockSummaryReportContent extends ConsumerStatefulWidget {
  const LowStockSummaryReportContent({super.key});

  @override
  ConsumerState<LowStockSummaryReportContent> createState() =>
      _LowStockSummaryReportContentState();
}

class _LowStockSummaryReportContentState
    extends ConsumerState<LowStockSummaryReportContent> {
  String _category = 'All Categories';
  bool _showItemsInStock = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(lowStockReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(lowStockReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
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
                  SaleFilterDropdown(
                    label: _category,
                    options: const [
                      'All Categories',
                      'Category A',
                      'Category B',
                    ],
                    selected: _category,
                    onSelected: (value) => setState(() => _category = value),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _showItemsInStock,
                        onChanged: (value) => setState(
                          () => _showItemsInStock = value ?? false,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Show items in stock',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
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
                    Expanded(
                      child: rows.isEmpty
                          ? const Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i]
                                                  .minStock
                                                  .toStringAsFixed(0),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            110,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              rows[i]
                                                  .currentStock
                                                  .toStringAsFixed(0),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].currentStock * 150,
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
