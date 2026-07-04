import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_filter_dropdown.dart';
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
        final totalSale =
            rows.fold<double>(0, (sum, row) => sum + row.saleAmount);
        final totalProfit =
            rows.fold<double>(0, (sum, row) => sum + row.profit);

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
                  children: const [
                    ReportTextActionButton(
                      label: 'Excel Report',
                      icon: Icons.table_chart_outlined,
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
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
                          SizedBox(
                            width: 180,
                            child: SaleFilterDropdown(
                              label: 'All Parties',
                              options: const [
                                'All Parties',
                                'Customers',
                                'Suppliers',
                              ],
                              selected: 'All Parties',
                              onSelected: (_) {},
                            ),
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
                      child: rows.isEmpty
                          ? const Center(
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
                            )
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                minWidth: 600,
                                headerChildren: const [
                                  ReportAlignedHeaderCell(label: '#', width: 40),
                                  Expanded(
                                    child: ReportAlignedHeaderCell(
                                      label: 'PARTY NAME',
                                    ),
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'PHONE NO.',
                                    width: 120,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'TOTAL SALE AMOUNT',
                                    width: 150,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'PROFIT (+) / LOSS (-)',
                                    width: 150,
                                    alignment: Alignment.centerRight,
                                  ),
                                ],
                                rows: [
                                  for (var i = 0; i < rows.length; i++)
                                    ReportAlignedRowStrip(
                                      index: i,
                                      child: ReportAlignedDataRow(
                                        cells: [
                                          ReportAlignedCell.fixed(
                                            40,
                                            child: Text('${i + 1}'),
                                          ),
                                          ReportAlignedCell.flex(
                                            child: Text(
                                              rows[i].partyName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            child: Text(rows[i].phone),
                                          ),
                                          ReportAlignedCell.fixed(
                                            150,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].saleAmount,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            150,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].profit,
                                              ),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: rows[i].profit >= 0
                                                    ? reportTeal
                                                    : Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: reportCardBorder)),
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
                                .read(partyWiseProfitLossReportProvider.notifier)
                                .goToPage(report.meta.page - 1)
                          : null,
                      onNext: report.meta.page < report.meta.totalPages
                          ? () => ref
                                .read(partyWiseProfitLossReportProvider.notifier)
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
