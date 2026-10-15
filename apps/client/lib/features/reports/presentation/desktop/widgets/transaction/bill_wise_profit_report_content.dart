import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/bill_wise_profit_transactions_table.dart';
import 'package:billing_baba/features/reports/utils/bill_wise_profit_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
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

        List<List<String>> exportRows() => [
          for (final row in rows) billWiseProfitExportRow(row),
        ];

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Bill Wise Profit',
            filename: 'bill-wise-profit',
            headers: billWiseProfitExportHeaders,
            rows: exportRows(),
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Bill Wise Profit',
            filename: 'bill-wise-profit',
            headers: billWiseProfitExportHeaders,
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
                        onTap: exportCsv,
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
                const Expanded(child: BillWiseProfitTransactionsTable()),
              ],
            ),
          ),
        );
      },
    );
  }
}
