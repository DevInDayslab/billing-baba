import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:billing_baba/features/reports/utils/report_table_builders.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SacReportContent extends ConsumerStatefulWidget {
  const SacReportContent({super.key});

  @override
  ConsumerState<SacReportContent> createState() => _SacReportContentState();
}

class _SacReportContentState extends ConsumerState<SacReportContent> {
  String _firm = 'All Firms';

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(sacReportReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(sacReportReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final filteredRows = _firm == 'All Firms' ? rows : rows;
        final totalValue = filteredRows.fold<double>(
          0,
          (sum, r) => sum + r.totalValue,
        );
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
          for (var i = 0; i < filteredRows.length; i++)
            [
              '${i + 1}',
              filteredRows[i].sac,
              filteredRows[i].invoiceType,
              formatReportCurrency(filteredRows[i].totalValue),
              formatReportCurrency(filteredRows[i].taxableValue),
              formatReportCurrency(filteredRows[i].igst),
              formatReportCurrency(filteredRows[i].cgst),
              formatReportCurrency(filteredRows[i].sgst),
              formatReportCurrency(filteredRows[i].cess),
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
                  child: ReportPeriodFilterBar(
                    showFirmFilter: false,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                            child: ReportFilterableSyncTable<ReportSacRow>(
                              reportScope: sacReportScope,
                              minWidth: 900,
                              columns: sacReportColumns(),
                              rows: filteredRows,
                              emptyState: const Center(
                                child: Text(
                                  'No data available for SAC report.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
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
                                'Total Items: ${filteredRows.length}',
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
