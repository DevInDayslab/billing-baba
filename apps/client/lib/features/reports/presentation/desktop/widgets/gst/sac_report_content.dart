import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_data_row.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SacReportContent extends ConsumerStatefulWidget {
  const SacReportContent({super.key});

  @override
  ConsumerState<SacReportContent> createState() => _SacReportContentState();
}

class _SacReportContentState extends ConsumerState<SacReportContent> {
  String _timeRange = 'This Month';
  String _firm = 'All Firms';

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(sacReportReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(sacReportReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalValue = rows.fold(0.0, (sum, r) => sum + r.totalValue);
        const exportHeaders = [
          '#',
          'SAC',
          'Invoice Type',
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
              rows[i].sac,
              rows[i].invoiceType,
              formatReportCurrency(rows[i].totalValue),
              formatReportCurrency(rows[i].taxableValue),
              formatReportCurrency(rows[i].igst),
              formatReportCurrency(rows[i].cgst),
              formatReportCurrency(rows[i].sgst),
              formatReportCurrency(rows[i].cess),
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
                      SaleFilterDropdown(
                        label: _firm,
                        options: const ['All Firms', 'Firm A', 'Firm B'],
                        selected: _firm,
                        onSelected: (value) => setState(() => _firm = value),
                      ),
                      ReportTextActionButton(
                        label: 'Excel Report',
                        icon: Icons.table_chart_outlined,
                        onTap: () => reportExportTable(
                          context: context,
                          title: 'SAC Report',
                          filename: 'sac-report',
                          headers: exportHeaders,
                          rows: exportRows,
                        ),
                      ),
                      ReportTextActionButton(
                        label: 'Print',
                        icon: Icons.print_outlined,
                        onTap: () => reportPrintTable(
                          context: context,
                          title: 'SAC Report',
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
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'SAC REPORT',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
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
                                    'No data available for SAC report.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : ReportSyncScrollTable(
                                    minWidth: 900,
                                    headerChildren: const [
                                      ReportAlignedHeaderCell(
                                        label: '#',
                                        width: 40,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'SAC',
                                        width: 90,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'INVOICE TYPE',
                                        width: 110,
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
                                                90,
                                                child: Text(rows[i].sac),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                child: Text(
                                                  rows[i].invoiceType,
                                                ),
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
                                                  formatReportCurrency(
                                                    rows[i].cess,
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
