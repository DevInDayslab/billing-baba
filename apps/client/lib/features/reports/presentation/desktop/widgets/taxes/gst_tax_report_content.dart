import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/taxes/taxes_report_filter_bar.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GstTaxReportContent extends ConsumerWidget {
  const GstTaxReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(gstTaxReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(gstTaxReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        const exportHeaders = [
          'Party Name',
          'Sale Tax',
          'Purchase / Expense Tax',
        ];
        final exportRows = [
          for (final row in rows)
            [
              row.partyName,
              formatReportCurrency(row.saleTax),
              formatReportCurrency(row.purchaseExpenseTax),
            ],
        ];

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
                child: TaxesReportFilterBar(
                  onExportExcel: () => reportExportTable(
                    context: context,
                    title: 'GST Tax Report',
                    filename: 'gst-tax-report',
                    headers: exportHeaders,
                    rows: exportRows,
                  ),
                  onPrint: () => reportPrintTable(
                    context: context,
                    title: 'GST Tax Report',
                    headers: exportHeaders,
                    rows: exportRows,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  'GST TAX REPORT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.4,
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
                        Expanded(
                          child: ReportTableArea(
                            child: ReportSyncScrollTable(
                              minWidth: 720,
                              headerChildren: const [
                                Expanded(
                                  child: ReportAlignedHeaderCell(
                                    label: 'Party Name',
                                  ),
                                ),
                                ReportAlignedHeaderCell(
                                  label: 'Sale Tax',
                                  width: 160,
                                  alignment: Alignment.centerRight,
                                ),
                                ReportAlignedHeaderCell(
                                  label: 'Purchase / Expense Tax',
                                  width: 200,
                                  alignment: Alignment.centerRight,
                                ),
                              ],
                              rows: [
                                for (var i = 0; i < rows.length; i++)
                                  ReportAlignedRowStrip(
                                    index: i,
                                    child: ReportAlignedDataRow(
                                      cells: [
                                        ReportAlignedCell.flex(
                                          child: Text(rows[i].partyName),
                                        ),
                                        ReportAlignedCell.fixed(
                                          160,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            formatReportCurrency(
                                              rows[i].saleTax,
                                            ),
                                          ),
                                        ),
                                        ReportAlignedCell.fixed(
                                          200,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            formatReportCurrency(
                                              rows[i].purchaseExpenseTax,
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
                        ReportPaginationBar(
                          page: report.meta.page,
                          totalPages: report.meta.totalPages,
                          onPrevious: report.meta.page > 1
                              ? () => ref
                                    .read(gstTaxReportProvider.notifier)
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(gstTaxReportProvider.notifier)
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
