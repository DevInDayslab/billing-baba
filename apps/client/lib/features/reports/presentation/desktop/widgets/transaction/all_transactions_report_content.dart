import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/phase1_report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/all_transactions_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/sale_report_filter_bar.dart';
import 'package:billing_baba/features/reports/utils/all_transactions_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllTransactionsReportContent extends ConsumerWidget {
  const AllTransactionsReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(allTransactionsReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(allTransactionsReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final meta = report.meta;
        final rowOffset = (meta.page - 1) * meta.limit;

        List<List<String>> exportRows() => [
          for (var i = 0; i < rows.length; i++)
            allTransactionsExportRow(rows[i], rowOffset + i + 1),
        ];

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'All Transactions',
            filename: 'all-transactions',
            headers: allTransactionsExportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'All Transactions',
            headers: allTransactionsExportHeaders,
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
                const SaleReportFilterBar(),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                const SizedBox(height: AppSpacing.md),
                const Expanded(child: AllTransactionsTransactionsTable()),
              ],
            ),
          ),
        );
      },
    );
  }
}
