import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/item_stock/stock_detail_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/stock_detail_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockDetailReportContent extends ConsumerWidget {
  const StockDetailReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(stockDetailReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(stockDetailReportProvider.notifier).refresh(),
      data: (report) {
        List<List<String>> exportRows() => [
          for (final row in report.rows) stockDetailExportRow(row),
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Stock Detail Report',
            filename: 'stock-detail-report',
            headers: stockDetailExportHeaders,
            rows: exportRows(),
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Stock Detail Report',
            headers: stockDetailExportHeaders,
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
                const Expanded(child: StockDetailTransactionsTable()),
              ],
            ),
          ),
        );
      },
    );
  }
}
