import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/models/taxes_report_subsection.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/presentation/widgets/taxes/taxes_report_filter_bar.dart';
import 'package:billing_baba/features/reports/providers/report_filters_provider.dart';
import 'package:billing_baba/features/reports/providers/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaxInvoiceReportContent extends ConsumerWidget {
  const TaxInvoiceReportContent({
    required this.subSection,
    super.key,
  });

  final TaxesReportSubSection subSection;

  static const _minTableWidth = 1180.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = switch (subSection) {
      TaxesReportSubSection.formNo27Eq => ref.watch(form27eqReportProvider),
      TaxesReportSubSection.tcsReceivable => ref.watch(
        tcsReceivableReportProvider,
      ),
      TaxesReportSubSection.tdsPayable => ref.watch(tdsPayableReportProvider),
      TaxesReportSubSection.tdsReceivable => ref.watch(
        tdsReceivableReportProvider,
      ),
      _ => null,
    };

    if (reportAsync == null) {
      return const SizedBox.shrink();
    }

    final onRetry = switch (subSection) {
      TaxesReportSubSection.formNo27Eq =>
        () => ref.read(form27eqReportProvider.notifier).refresh(),
      TaxesReportSubSection.tcsReceivable =>
        () => ref.read(tcsReceivableReportProvider.notifier).refresh(),
      TaxesReportSubSection.tdsPayable =>
        () => ref.read(tdsPayableReportProvider.notifier).refresh(),
      TaxesReportSubSection.tdsReceivable =>
        () => ref.read(tdsReceivableReportProvider.notifier).refresh(),
      _ => () {},
    };

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: onRetry,
      data: (report) {
        final rows = report.rows;
        const exportHeaders = [
          '#',
          'Party Name',
          'Invoice No',
          'Total Value',
          'Amount Received',
          'Total Tax Collected',
          'Date of Collection',
          'Tax Name',
          'TCS Rate',
        ];
        final exportRows = [
          for (var i = 0; i < rows.length; i++)
            [
              '${i + 1}',
              rows[i].partyName,
              rows[i].invoiceNo,
              formatReportCurrency(rows[i].totalValue),
              formatReportCurrency(rows[i].amountReceived),
              formatReportCurrency(rows[i].totalTaxCollected),
              formatReportDate(rows[i].collectionDate),
              rows[i].taxName,
              rows[i].taxRate.toStringAsFixed(2),
            ],
        ];

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      subSection.pageTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ReportCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TaxInvoiceReportFilterBar(
                          onExportExcel: () => reportExportTable(
                            context: context,
                            title: subSection.pageTitle,
                            filename: 'tax-invoice-report',
                            headers: exportHeaders,
                            rows: exportRows,
                          ),
                          onPrint: () => reportPrintTable(
                            context: context,
                            title: subSection.pageTitle,
                            headers: exportHeaders,
                            rows: exportRows,
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: ReportSearchField(
                            onChanged: ref
                                .read(reportFiltersProvider.notifier)
                                .setSearchQuery,
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportTableArea(
                            child: rows.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.description_outlined,
                                        size: 48,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.4),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        subSection.emptyMessage,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ReportSyncScrollTable(
                                        minWidth: _minTableWidth,
                                        headerChildren: const [
                                          ReportAlignedHeaderCell(
                                            label: '#',
                                            width: 40,
                                            showFilter: false,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'PARTY NAME',
                                            width: 140,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'INVOICE NO',
                                            width: 110,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'TOTAL VALUE',
                                            width: 120,
                                            alignment: Alignment.centerRight,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'AMOUNT RECEIVED',
                                            width: 140,
                                            alignment: Alignment.centerRight,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'TOTAL TAX COLLECTED',
                                            width: 160,
                                            alignment: Alignment.centerRight,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'DATE OF COLLECTION',
                                            width: 150,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'TAX NAME',
                                            width: 120,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'TCS RATE',
                                            width: 100,
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
                                                    140,
                                                    child: Text(
                                                      rows[i].partyName,
                                                    ),
                                                  ),
                                                  ReportAlignedCell.fixed(
                                                    110,
                                                    child: Text(
                                                      rows[i].invoiceNo,
                                                    ),
                                                  ),
                                                  ReportAlignedCell.fixed(
                                                    120,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      formatReportCurrency(
                                                        rows[i].totalValue,
                                                      ),
                                                    ),
                                                  ),
                                                  ReportAlignedCell.fixed(
                                                    140,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      formatReportCurrency(
                                                        rows[i].amountReceived,
                                                      ),
                                                    ),
                                                  ),
                                                  ReportAlignedCell.fixed(
                                                    160,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      formatReportCurrency(
                                                        rows[i]
                                                            .totalTaxCollected,
                                                      ),
                                                    ),
                                                  ),
                                                  ReportAlignedCell.fixed(
                                                    150,
                                                    child: Text(
                                                      formatReportDate(
                                                        rows[i].collectionDate,
                                                      ),
                                                    ),
                                                  ),
                                                  ReportAlignedCell.fixed(
                                                    120,
                                                    child: Text(
                                                      rows[i].taxName,
                                                    ),
                                                  ),
                                                  ReportAlignedCell.fixed(
                                                    100,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      rows[i].taxRate
                                                          .toStringAsFixed(2),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    ReportPaginationBar(
                                      page: report.meta.page,
                                      totalPages: report.meta.totalPages,
                                      onPrevious: report.meta.page > 1
                                          ? () => _goToPage(
                                              ref,
                                              report.meta.page - 1,
                                            )
                                          : null,
                                      onNext:
                                          report.meta.page <
                                              report.meta.totalPages
                                          ? () => _goToPage(
                                              ref,
                                              report.meta.page + 1,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToPage(WidgetRef ref, int page) {
    switch (subSection) {
      case TaxesReportSubSection.formNo27Eq:
        ref.read(form27eqReportProvider.notifier).goToPage(page);
      case TaxesReportSubSection.tcsReceivable:
        ref.read(tcsReceivableReportProvider.notifier).goToPage(page);
      case TaxesReportSubSection.tdsPayable:
        ref.read(tdsPayableReportProvider.notifier).goToPage(page);
      case TaxesReportSubSection.tdsReceivable:
        ref.read(tdsReceivableReportProvider.notifier).goToPage(page);
      default:
        break;
    }
  }
}
