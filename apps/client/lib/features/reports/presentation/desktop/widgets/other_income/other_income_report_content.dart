import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_filterable_sync_table.dart';
import 'package:billing_baba/features/reports/utils/report_table_builders.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_search_field.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtherIncomeReportContent extends ConsumerWidget {
  const OtherIncomeReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(otherIncomeReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(otherIncomeReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalAmount = report.totalAmount;

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Other Income',
            filename: 'other-income-report',
            headers: const [
              'Date',
              'Inc No',
              'Party',
              'Category',
              'Payment Type',
              'Amount',
              'Due Date',
              'Status',
            ],
            rows: [
              for (final row in rows)
                [
                  formatReportDate(row.date),
                  row.incomeNo,
                  row.partyName,
                  row.category,
                  row.paymentType,
                  formatReportCurrency(row.amount),
                  formatReportDate(row.dueDate),
                  row.status,
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
                child: ReportTitleActionsRow(
                  title: 'Other Income',
                  actions: [
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
                        title: 'Other Income',
                        content: ReportExportService.toCsv(
                          headers: const [
                            'Date',
                            'Inc No',
                            'Party',
                            'Category',
                            'Payment Type',
                            'Amount',
                            'Due Date',
                            'Status',
                          ],
                          rows: [
                            for (final row in rows)
                              [
                                formatReportDate(row.date),
                                row.incomeNo,
                                row.partyName,
                                row.category,
                                row.paymentType,
                                formatReportCurrency(row.amount),
                                formatReportDate(row.dueDate),
                                row.status,
                              ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ReportCard(
                  backgroundColor: Color(0xFFF5F7FA),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: ReportFromToDateFilter(),
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
                                'TRANSACTIONS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: ReportSearchField(
                                  hintText: 'Search other income...',
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
                            child: ReportFilterableSyncTable<ReportOtherIncomeRow>(
                              reportScope: otherIncomeReportScope,
                              columns: otherIncomeReportColumns(),
                              rows: rows,
                              emptyState: const Center(
                                child: Text(
                                  'No other income records found for the selected period.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _TotalFooter(
                          label: 'Total Amount: ',
                          amount: formatReportCurrency(totalAmount),
                          amountColor: reportTeal,
                        ),
                        ReportPaginationBar(
                          page: report.meta.page,
                          totalPages: report.meta.totalPages,
                          onPrevious: report.meta.page > 1
                              ? () => ref
                                    .read(otherIncomeReportProvider.notifier)
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(otherIncomeReportProvider.notifier)
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

class OtherIncomeCategoryReportContent extends ConsumerWidget {
  const OtherIncomeCategoryReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(otherIncomeByCategoryReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(otherIncomeByCategoryReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalIncome = rows.fold<double>(
          0,
          (sum, row) => sum + row.amount,
        );

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Other Income Category Report',
            filename: 'other-income-category-report',
            headers: const ['Income Category', 'Count', 'Amount'],
            rows: [
              for (final row in rows)
                [
                  row.category,
                  '${row.count}',
                  formatReportCurrency(row.amount),
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
                child: ReportTitleActionsRow(
                  title: 'Other Income Category Report',
                  actions: [
                    ReportTextActionButton(
                      label: 'Excel',
                      icon: Icons.table_chart_outlined,
                      onTap: exportCsv,
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: () => ReportExportService.showPrintPreview(
                        context: context,
                        title: 'Other Income Category Report',
                        content: ReportExportService.toCsv(
                          headers: const ['Income Category', 'Count', 'Amount'],
                          rows: [
                            for (final row in rows)
                              [
                                row.category,
                                '${row.count}',
                                formatReportCurrency(row.amount),
                              ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ReportCard(
                  backgroundColor: Color(0xFFF5F7FA),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: ReportFromToDateFilter(betweenLabel: 'From'),
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
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'OTHER INCOME',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ReportTableArea(
                            child: ReportFilterableSyncTable<
                                ReportOtherIncomeCategoryRow>(
                              reportScope: otherIncomeCategoryReportScope,
                              columns: otherIncomeCategoryReportColumns(),
                              rows: rows,
                              emptyState: const Center(
                                child: Text(
                                  'No other income records found for the selected period.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _TotalFooter(
                          label: 'Total Income: ',
                          amount: formatReportCurrency(totalIncome),
                          amountColor: reportTeal,
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

class OtherIncomeItemReportContent extends ConsumerWidget {
  const OtherIncomeItemReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(otherIncomeByItemReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(otherIncomeByItemReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalIncome = rows.fold<double>(
          0,
          (sum, row) => sum + row.amount,
        );

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Other Income Item Report',
            filename: 'other-income-item-report',
            headers: const ['Income Item', 'Category', 'Amount'],
            rows: [
              for (final row in rows)
                [
                  row.itemName,
                  row.category,
                  formatReportCurrency(row.amount),
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
                child: ReportTitleActionsRow(
                  title: 'Other Income Item Report',
                  actions: [
                    ReportTextActionButton(
                      label: 'Excel',
                      icon: Icons.table_chart_outlined,
                      onTap: exportCsv,
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: () => ReportExportService.showPrintPreview(
                        context: context,
                        title: 'Other Income Item Report',
                        content: ReportExportService.toCsv(
                          headers: const ['Income Item', 'Category', 'Amount'],
                          rows: [
                            for (final row in rows)
                              [
                                row.itemName,
                                row.category,
                                formatReportCurrency(row.amount),
                              ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ReportCard(
                  backgroundColor: Color(0xFFF5F7FA),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: ReportFromToDateFilter(betweenLabel: 'From'),
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
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: Text(
                            'OTHER INCOME',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ReportTableArea(
                            child: ReportFilterableSyncTable<ReportOtherIncomeItemRow>(
                              reportScope: otherIncomeItemReportScope,
                              columns: otherIncomeItemReportColumns(),
                              rows: rows,
                              emptyState: const Center(
                                child: Text(
                                  'No other income records found for the selected period.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _TotalFooter(
                          label: 'Total Income: ',
                          amount: formatReportCurrency(totalIncome),
                          amountColor: reportTeal,
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

class _TotalFooter extends StatelessWidget {
  const _TotalFooter({
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String label;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: reportCardBorder)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 14),
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              TextSpan(
                text: amount,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
