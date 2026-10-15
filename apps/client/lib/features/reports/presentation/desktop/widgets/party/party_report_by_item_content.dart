import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/party/party_report_by_item_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/party_report_by_item_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyReportByItemContent extends ConsumerWidget {
  const PartyReportByItemContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(partyReportByItemReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(partyReportByItemReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report?.rows ?? const [];

        List<List<String>> exportRows() => [
          for (final row in rows) partyReportByItemExportRow(row),
        ];

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Party Report By Item',
            filename: 'party-report-by-item',
            headers: partyReportByItemExportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Party Report By Item',
            headers: partyReportByItemExportHeaders,
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
                const Expanded(child: PartyReportByItemTransactionsTable()),
              ],
            ),
          ),
        );
      },
    );
  }
}
