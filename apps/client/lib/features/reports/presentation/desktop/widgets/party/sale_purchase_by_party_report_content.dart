import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/party/sale_purchase_by_party_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseByPartyReportContent extends ConsumerWidget {
  const SalePurchaseByPartyReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salePurchaseByPartyReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(salePurchaseByPartyReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Sale Purchase By Party',
            filename: 'sale-purchase-by-party',
            headers: const [
              'Party Name',
              'Sale Amount',
              'Purchase Amount',
              'Receivable',
              'Payable',
            ],
            rows: [
              for (final row in rows)
                [
                  row.partyName,
                  formatReportCurrency(row.saleAmount),
                  formatReportCurrency(row.purchaseAmount),
                  '',
                  '',
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
                  AppSpacing.md,
                ),
                child: ReportPeriodFilterBar(
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
                        onTap: () => ReportExportService.showPrintPreview(
                          context: context,
                          title: 'Sale Purchase By Party',
                          content: ReportExportService.toCsv(
                            headers: const [
                              'Party Name',
                              'Sale Amount',
                              'Purchase Amount',
                            ],
                            rows: [
                              for (final row in rows)
                                [
                                  row.partyName,
                                  formatReportCurrency(row.saleAmount),
                                  formatReportCurrency(row.purchaseAmount),
                                ],
                            ],
                          ),
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
                    child: const SalePurchaseByPartyTransactionsTable(),
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
