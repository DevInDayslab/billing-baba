import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/utils/report_table_builders.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyWiseProfitLossReportContent extends ConsumerWidget {
  const PartyWiseProfitLossReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(partyWiseProfitLossReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(partyWiseProfitLossReportProvider.notifier).refresh(),
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

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Party Wise Profit / Loss',
            filename: 'party-wise-profit-loss',
            headers: const [
              'Party Name',
              'Phone No.',
              'Total Sale Amount',
              'Profit (+) / Loss (-)',
            ],
            rows: [
              for (final row in rows)
                [
                  row.partyName,
                  row.phone,
                  formatReportCurrency(row.saleAmount),
                  formatReportCurrency(row.profit),
                ],
            ],
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Party Wise Profit / Loss',
            headers: const [
              'Party Name',
              'Phone No.',
              'Total Sale Amount',
              'Profit (+) / Loss (-)',
            ],
            rows: [
              for (final row in rows)
                [
                  row.partyName,
                  row.phone,
                  formatReportCurrency(row.saleAmount),
                  formatReportCurrency(row.profit),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ReportPeriodFilterBar(),
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
                  ],
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
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 180,
                                child: ReportPartyTypeFilter(),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: ReportSearchField(
                                  onChanged: ref
                                      .read(reportFiltersProvider.notifier)
                                      .setSearchQuery,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ReportTableArea(
                            child:
                                ReportFilterableSyncTable<
                                  ReportPartyWiseProfitLossRow
                                >(
                                  reportScope: partyWiseProfitLossReportScope,
                                  minWidth: 600,
                                  columns: partyWiseProfitLossColumns(),
                                  rows: rows,
                                  emptyState: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'No data available.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'Try adjusting the date range or filters.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Total Sale Amount: ${formatReportCurrency(totalSale)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Total Profit(+) / Loss (-): '
                                '${formatReportCurrency(totalProfit)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
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
                                      partyWiseProfitLossReportProvider
                                          .notifier,
                                    )
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(
                                      partyWiseProfitLossReportProvider
                                          .notifier,
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
