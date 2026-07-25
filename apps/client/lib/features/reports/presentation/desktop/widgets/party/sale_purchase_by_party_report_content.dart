import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filter_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
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
    final parties = ref.watch(partiesListProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(salePurchaseByPartyReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final partyByName = {
          for (final party in parties) party.name: party,
        };
        final totalSale = rows.fold<double>(
          0,
          (sum, row) => sum + row.saleAmount,
        );
        final totalPurchase = rows.fold<double>(
          0,
          (sum, row) => sum + row.purchaseAmount,
        );

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
                              : ReportSyncScrollTable(
                                    minWidth: 650,
                                    headerChildren: const [
                                      ReportAlignedHeaderCell(
                                        label: '#',
                                        width: 40,
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
                                        width: 140,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'RECEIVABLE',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'PAYABLE',
                                        width: 100,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ],
                                    rows: [
                                      for (var i = 0; i < rows.length; i++)
                                        ReportAlignedRowStrip(
                                          index: i,
                                          child: _SalePurchaseRow(
                                            index: i,
                                            partyName: rows[i].partyName,
                                            saleAmount: rows[i].saleAmount,
                                            purchaseAmount:
                                                rows[i].purchaseAmount,
                                            party:
                                                partyByName[rows[i].partyName],
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
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
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
                            ],
                          ),
                        ),
                        ReportPaginationBar(
                          page: report.meta.page,
                          totalPages: report.meta.totalPages,
                          onPrevious: report.meta.page > 1
                              ? () => ref
                                    .read(
                                      salePurchaseByPartyReportProvider
                                          .notifier,
                                    )
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(
                                      salePurchaseByPartyReportProvider
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

class _SalePurchaseRow extends StatelessWidget {
  const _SalePurchaseRow({
    required this.index,
    required this.partyName,
    required this.saleAmount,
    required this.purchaseAmount,
    required this.party,
  });

  final int index;
  final String partyName;
  final double saleAmount;
  final double purchaseAmount;
  final PartyModel? party;

  @override
  Widget build(BuildContext context) {
    final balance = party?.balance ?? 0;
    final receivable = balance > 0 ? formatReportCurrency(balance) : '—';
    final payable = balance < 0 ? formatReportCurrency(balance.abs()) : '—';

    return ReportAlignedDataRow(
      cells: [
        ReportAlignedCell.fixed(40, child: Text('${index + 1}')),
        ReportAlignedCell.flex(
          child: Text(
            partyName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ReportAlignedCell.fixed(
          120,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrency(saleAmount)),
        ),
        ReportAlignedCell.fixed(
          140,
          alignment: Alignment.centerRight,
          child: Text(formatReportCurrency(purchaseAmount)),
        ),
        ReportAlignedCell.fixed(
          110,
          alignment: Alignment.centerRight,
          child: Text(receivable),
        ),
        ReportAlignedCell.fixed(
          100,
          alignment: Alignment.centerRight,
          child: Text(payable),
        ),
      ],
    );
  }
}
