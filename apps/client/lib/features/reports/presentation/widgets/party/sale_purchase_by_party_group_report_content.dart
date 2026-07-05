import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalePurchaseByPartyGroupReportContent extends ConsumerWidget {
  const SalePurchaseByPartyGroupReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salePurchaseByPartyGroupReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref
          .read(salePurchaseByPartyGroupReportProvider.notifier)
          .refresh(),
      data: (report) {
        final rows = report.rows;
        final totalSale =
            rows.fold<double>(0, (sum, row) => sum + row.saleAmount);
        final totalPurchase =
            rows.fold<double>(0, (sum, row) => sum + row.purchaseAmount);
        final netBalance = totalSale - totalPurchase;

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Sale Purchase By Party Group',
            filename: 'sale-purchase-by-party-group',
            headers: const [
              'Party Group',
              'Party Name',
              'Sale Amount',
              'Purchase Amount',
              'Net Balance',
            ],
            rows: [
              for (final row in rows)
                [
                  row.partyGroup,
                  row.partyName,
                  formatReportCurrency(row.saleAmount),
                  formatReportCurrency(row.purchaseAmount),
                  formatReportCurrency(row.saleAmount - row.purchaseAmount),
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
                      title: 'Sale Purchase By Party Group',
                      content: ReportExportService.toCsv(
                        headers: const [
                          'Party Group',
                          'Party Name',
                          'Sale Amount',
                          'Purchase Amount',
                          'Net Balance',
                        ],
                        rows: [
                          for (final row in rows)
                            [
                              row.partyGroup,
                              row.partyName,
                              formatReportCurrency(row.saleAmount),
                              formatReportCurrency(row.purchaseAmount),
                              formatReportCurrency(
                                row.saleAmount - row.purchaseAmount,
                              ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 160,
                            child: ReportPartyGroupFilter(),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const SizedBox(
                            width: 160,
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
                      child: rows.isEmpty
                          ? const Center(
                              child: Text(
                                'No data available for the selected period.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: ReportSyncScrollTable(
                                minWidth: 700,
                                headerChildren: const [
                                  ReportAlignedHeaderCell(label: '#', width: 40),
                                  ReportAlignedHeaderCell(
                                    label: 'PARTY GROUP',
                                    width: 130,
                                  ),
                                  Expanded(
                                    child: ReportAlignedHeaderCell(
                                      label: 'PARTY NAME',
                                    ),
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'SALE AMOUNT',
                                    width: 120,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'PURCHASE AMOUNT',
                                    width: 130,
                                    alignment: Alignment.centerRight,
                                  ),
                                  ReportAlignedHeaderCell(
                                    label: 'NET BALANCE',
                                    width: 110,
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
                                          ReportAlignedCell.fixed(
                                            130,
                                            child: Text(rows[i].partyGroup),
                                          ),
                                          ReportAlignedCell.flex(
                                            child: Text(
                                              rows[i].partyName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            120,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].saleAmount,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            130,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].purchaseAmount,
                                              ),
                                            ),
                                          ),
                                          ReportAlignedCell.fixed(
                                            110,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              formatReportCurrency(
                                                rows[i].saleAmount -
                                                    rows[i].purchaseAmount,
                                              ),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    rows[i].saleAmount -
                                                            rows[i]
                                                                .purchaseAmount >=
                                                        0
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
                            'Total Sale: ${formatReportCurrency(totalSale)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Total Purchase: ${formatReportCurrency(totalPurchase)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Text(
                            'Net Balance: ${formatReportCurrency(netBalance)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
                                  salePurchaseByPartyGroupReportProvider
                                      .notifier,
                                )
                                .goToPage(report.meta.page - 1)
                          : null,
                      onNext: report.meta.page < report.meta.totalPages
                          ? () => ref
                                .read(
                                  salePurchaseByPartyGroupReportProvider
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
