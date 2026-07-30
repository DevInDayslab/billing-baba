import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/utils/report_table_builders.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConsumptionReportContent extends ConsumerWidget {
  const ConsumptionReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(consumptionReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(consumptionReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalQty = rows.fold<double>(0, (sum, row) => sum + row.quantity);
        final totalAmount = rows.fold<double>(0, (sum, row) => sum + row.value);

        const exportHeaders = [
          '#',
          'Item Name',
          'Date',
          'Qty Consumed',
          'Amount',
        ];

        List<List<String>> exportRows() => [
          for (var i = 0; i < rows.length; i++)
            [
              '${i + 1}',
              rows[i].itemName,
              formatReportDate(rows[i].date),
              rows[i].quantity.toStringAsFixed(0),
              formatReportCurrency(rows[i].value),
            ],
        ];

        void exportExcel() {
          reportExportTable(
            context: context,
            title: 'Consumption Report',
            filename: 'consumption-report',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

        void printReport() {
          reportPrintTable(
            context: context,
            title: 'Consumption Report',
            headers: exportHeaders,
            rows: exportRows(),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
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
                                'Consumption Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              ReportTextActionButton(
                                label: 'Excel Report',
                                icon: Icons.table_chart_outlined,
                                onTap: exportExcel,
                              ),
                              ReportTextActionButton(
                                label: 'Print',
                                icon: Icons.print_outlined,
                                onTap: printReport,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: reportTableHeaderBg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: const Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ReportDateRangeChipFilter(),
                              SizedBox(
                                width: 260,
                                child: ReportSearchField(
                                  hintText: 'Search by item name...',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: reportCardBorder),
                        Expanded(
                          child: ReportTableArea(
                            child: ReportFilterableSyncTable<ReportConsumptionRow>(
                              reportScope: consumptionReportScope,
                              columns: consumptionColumns(),
                              rows: rows,
                              emptyState: const Center(
                                child: Text(
                                  'No consumption records found for the selected period.',
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
                            vertical: AppSpacing.sm,
                          ),
                          decoration: const BoxDecoration(
                            color: reportTableHeaderBg,
                            border: Border(
                              top: BorderSide(color: reportCardBorder),
                            ),
                          ),
                          child: Wrap(
                            spacing: AppSpacing.lg,
                            runSpacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Total Qty Consumed: ${totalQty.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Total Amount: ${formatReportCurrency(totalAmount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
}
