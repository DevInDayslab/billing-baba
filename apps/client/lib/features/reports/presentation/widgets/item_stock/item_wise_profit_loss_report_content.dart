import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemWiseProfitLossReportContent extends ConsumerStatefulWidget {
  const ItemWiseProfitLossReportContent({super.key});

  @override
  ConsumerState<ItemWiseProfitLossReportContent> createState() =>
      _ItemWiseProfitLossReportContentState();
}

class _ItemWiseProfitLossReportContentState
    extends ConsumerState<ItemWiseProfitLossReportContent> {
  String _firm = 'ALL FIRMS';
  bool _showInactiveItems = false;
  bool _itemsHavingSale = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(itemWiseProfitLossReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(itemWiseProfitLossReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalSale = rows.fold<double>(
          0,
          (sum, row) => sum + row.saleAmount,
        );
        final totalProfit = rows.fold<double>(
          0,
          (sum, row) => sum + row.profit,
        );
        const exportHeaders = [
          'Item Name',
          'Sale',
          'CR. Note / Sale Return',
          'Purchase',
          'DR. Note / Purchase Return',
          'Opening Stock',
          'Closing Stock',
          'Tax Receivable',
          'Tax Payable',
          'MFG. Cost',
          'Consumption Cost',
          'Net Profit/Loss',
        ];
        final exportRows = [
          for (final row in rows)
            [
              row.itemName,
              formatReportCurrency(row.saleAmount),
              '-',
              formatReportCurrency(row.purchaseAmount),
              '-',
              '-',
              '-',
              '-',
              '-',
              '-',
              '-',
              formatReportCurrency(row.profit),
            ],
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
                      SaleFilterDropdown(
                        label: _firm,
                        options: const ['ALL FIRMS', 'Firm A', 'Firm B'],
                        selected: _firm,
                        onSelected: (value) => setState(() => _firm = value),
                      ),
                      const ReportFromToDateFilter(betweenLabel: 'From'),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _showInactiveItems,
                            onChanged: (value) => setState(
                              () => _showInactiveItems = value ?? false,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          const Text(
                            'Show Inactive Items',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _itemsHavingSale,
                            onChanged: (value) => setState(
                              () => _itemsHavingSale = value ?? false,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          const Text(
                            'Items Having Sale',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      ReportTextActionButton(
                        label: 'Excel',
                        icon: Icons.table_chart_outlined,
                        onTap: () => reportExportTable(
                          context: context,
                          title: 'Item Wise Profit / Loss',
                          filename: 'item-wise-profit-loss',
                          headers: exportHeaders,
                          rows: exportRows,
                        ),
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: () => reportPrintTable(
                          context: context,
                          title: 'Item Wise Profit / Loss',
                          headers: exportHeaders,
                          rows: exportRows,
                        ),
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
                            'DETAILS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
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
                                      minWidth: 1320,
                                      headerChildren: [
                                        ReportAlignedHeaderCell(
                                          label: 'ITEM NAME',
                                          width: 140,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'SALE',
                                          width: 90,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'CR. NOTE / SALE RETURN',
                                          width: 150,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'PURCHASE',
                                          width: 100,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'DR. NOTE / PURCHASE RETURN',
                                          width: 170,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'OPENING STOCK',
                                          width: 120,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'CLOSING STOCK',
                                          width: 120,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'TAX RECEIVABLE',
                                          width: 120,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'TAX PAYABLE',
                                          width: 110,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'MFG. COST',
                                          width: 100,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'CONSUMPTION COST',
                                          width: 140,
                                          alignment: Alignment.centerRight,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'NET PROFIT/LOSS',
                                          width: 120,
                                          alignment: Alignment.centerRight,
                                        ),
                                      ],
                                      rows: [],
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'No data for the selected period.',
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
                                    minWidth: 1320,
                                    headerChildren: const [
                                      ReportAlignedHeaderCell(
                                        label: 'ITEM NAME',
                                        width: 140,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'SALE',
                                        width: 90,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'CR. NOTE / SALE RETURN',
                                        width: 150,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'PURCHASE',
                                        width: 100,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'DR. NOTE / PURCHASE RETURN',
                                        width: 170,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'OPENING STOCK',
                                        width: 120,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'CLOSING STOCK',
                                        width: 120,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'TAX RECEIVABLE',
                                        width: 120,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'TAX PAYABLE',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'MFG. COST',
                                        width: 100,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'CONSUMPTION COST',
                                        width: 140,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'NET PROFIT/LOSS',
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
                                              ReportAlignedCell.fixed(
                                                140,
                                                child: Text(rows[i].itemName),
                                              ),
                                              ReportAlignedCell.fixed(
                                                90,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].saleAmount,
                                                  ),
                                                ),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                150,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              ReportAlignedCell.fixed(
                                                100,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].purchaseAmount,
                                                  ),
                                                ),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                170,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                120,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                120,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                120,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                100,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                140,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              ReportAlignedCell.fixed(
                                                120,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].profit,
                                                  ),
                                                  style: TextStyle(
                                                    color: rows[i].profit >= 0
                                                        ? reportTeal
                                                        : reportAddRed,
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
                          child: Wrap(
                            spacing: AppSpacing.lg,
                            runSpacing: AppSpacing.sm,
                            children: [
                              Text(
                                'Total Sale: ${formatReportCurrency(totalSale)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Total Profit (+) / Loss (-): ${formatReportCurrency(totalProfit)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: reportTeal,
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
                                    .read(
                                      itemWiseProfitLossReportProvider.notifier,
                                    )
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(
                                      itemWiseProfitLossReportProvider.notifier,
                                    )
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
