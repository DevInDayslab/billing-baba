import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaleSummaryByHsnReportContent extends ConsumerStatefulWidget {
  const SaleSummaryByHsnReportContent({super.key});

  @override
  ConsumerState<SaleSummaryByHsnReportContent> createState() =>
      _SaleSummaryByHsnReportContentState();
}

class _SaleSummaryByHsnReportContentState
    extends ConsumerState<SaleSummaryByHsnReportContent> {
  String _timeRange = 'This Month';

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(saleSummaryByHsnReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(saleSummaryByHsnReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalValue = rows.fold<double>(0, (sum, r) => sum + r.totalValue);
        const exportHeaders = [
          '#',
          'HSN',
          'Total Value',
          'Taxable Value',
          'IGST Amount',
          'CGST Amount',
          'SGST Amount',
          'Add. Cess',
        ];
        final exportRows = [
          for (var i = 0; i < rows.length; i++)
            [
              '${i + 1}',
              rows[i].hsn,
              formatReportCurrency(rows[i].totalValue),
              formatReportCurrency(rows[i].taxableValue),
              formatReportCurrency(rows[i].igst),
              formatReportCurrency(rows[i].cgst),
              formatReportCurrency(rows[i].sgst),
              formatReportCurrency(0),
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
                child: ReportCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SaleFilterDropdown(
                        label: _timeRange,
                        options: const [
                          'All Time',
                          'Today',
                          'This Week',
                          'This Month',
                          'This Year',
                          'Custom',
                        ],
                        selected: _timeRange,
                        onSelected: (value) =>
                            setState(() => _timeRange = value),
                      ),
                      const ReportDateRangeChipFilter(),
                      ReportTextActionButton(
                        label: 'Excel',
                        icon: Icons.table_chart_outlined,
                        onTap: () => reportExportTable(
                          context: context,
                          title: 'Sale Summary by HSN',
                          filename: 'sale-summary-by-hsn',
                          headers: exportHeaders,
                          rows: exportRows,
                        ),
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: () => reportPrintTable(
                          context: context,
                          title: 'Sale Summary by HSN',
                          headers: exportHeaders,
                          rows: exportRows,
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
                          child: ReportSearchField(
                            hintText: 'Search by HSN...',
                            onChanged: ref
                                .read(reportFiltersProvider.notifier)
                                .setSearchQuery,
                          ),
                        ),
                        Expanded(
                          child: ReportTableArea(
                            child: rows.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'No data available for Sale Summary by HSN.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Create sale invoices with items that have HSN codes assigned.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ReportSyncScrollTable(
                                    minWidth: 800,
                                    headerChildren: const [
                                      ReportAlignedHeaderCell(
                                        label: '#',
                                        width: 40,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'HSN',
                                        width: 100,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'TOTAL VALUE',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'TAXABLE VALUE',
                                        width: 120,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'IGST AMOUNT',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'CGST AMOUNT',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'SGST AMOUNT',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'ADD. CESS',
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
                                                100,
                                                child: Text(rows[i].hsn),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].totalValue,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                120,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].taxableValue,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].igst,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].cgst,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].sgst,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                100,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(0),
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
                            vertical: AppSpacing.md,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text.rich(
                                TextSpan(
                                  style: const TextStyle(fontSize: 14),
                                  children: [
                                    const TextSpan(
                                      text: 'Total Value: ',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: formatReportCurrency(totalValue),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: reportTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Total Items: ${rows.length}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
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
