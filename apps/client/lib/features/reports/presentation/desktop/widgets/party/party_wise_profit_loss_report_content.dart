import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/party/party_wise_profit_loss_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyWiseProfitLossReportContent extends ConsumerWidget {
  const PartyWiseProfitLossReportContent({super.key});

  static const _exportHeaders = [
    'Party Name',
    'Phone No.',
    'Sale',
    'Purchase',
    'Profit (+) / Loss (-)',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(partyWiseProfitLossReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(partyWiseProfitLossReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;

        List<List<String>> exportRows() => [
          for (final row in rows)
            [
              row.partyName,
              row.phone,
              formatReportCurrency(row.saleAmount),
              formatReportCurrency(row.purchaseAmount),
              formatReportCurrency(row.profit),
            ],
        ];

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Party Wise Profit / Loss',
            filename: 'party-wise-profit-loss',
            headers: _exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Party Wise Profit / Loss',
            headers: _exportHeaders,
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
                        onTap: printReport,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Expanded(child: PartyWiseProfitLossTransactionsTable()),
              ],
            ),
          ),
        );
      },
    );
  }
}
