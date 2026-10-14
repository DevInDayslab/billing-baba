import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/transaction/cash_flow_transactions_table.dart';
import 'package:billing_baba/features/reports/utils/cash_flow_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CashFlowReportContent extends ConsumerWidget {
  const CashFlowReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(cashFlowReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(cashFlowReportProvider.notifier).refresh(),
      data: (report) {
        List<List<String>> exportRows() {
          var runningBalance = report.openingBalance;
          final rows = <List<String>>[];
          for (final row in report.rows) {
            runningBalance += row.moneyIn - row.moneyOut;
            rows.add(cashFlowExportRow(row, runningBalance));
          }
          return rows;
        }

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Cash Flow',
            filename: 'cash-flow',
            headers: cashFlowExportHeaders,
            rows: exportRows(),
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Cash Flow',
            headers: cashFlowExportHeaders,
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
                Text(
                  'Opening Cash-in Hand: '
                  '${formatReportCurrency(report.openingBalance)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: reportTeal,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Expanded(child: CashFlowTransactionsTable()),
              ],
            ),
          ),
        );
      },
    );
  }
}
