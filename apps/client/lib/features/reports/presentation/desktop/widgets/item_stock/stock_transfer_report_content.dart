import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/item_stock/stock_transfer_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/stock_transfer_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockTransferReportContent extends ConsumerWidget {
  const StockTransferReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(stockTransferReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(stockTransferReportProvider.notifier).refresh(),
      data: (report) {
        List<List<String>> exportRows() => [
          for (final row in report.rows) stockTransferExportRow(row),
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Stock Transfer Report',
            filename: 'stock-transfer-report',
            headers: stockTransferExportHeaders,
            rows: exportRows(),
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Stock Transfer Report',
            headers: stockTransferExportHeaders,
            rows: exportRows(),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
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
                  child: StockTransferTransactionsTable(
                    totalQtyTransferred: report.resolvedTotalQtyTransferred,
                    totalValue: report.resolvedTotalValue,
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
