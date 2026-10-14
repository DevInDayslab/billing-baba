import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/item_stock/stock_summary_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockSummaryReportContent extends ConsumerWidget {
  const StockSummaryReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(stockSummaryReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(stockSummaryReportProvider.notifier).refresh(),
      data: (report) {
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
              for (final row in report.rows)
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
              for (final row in report.rows)
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
                  0,
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
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: StockSummaryTransactionsTable(
                    totalStockValue: report.totalStockValue,
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
