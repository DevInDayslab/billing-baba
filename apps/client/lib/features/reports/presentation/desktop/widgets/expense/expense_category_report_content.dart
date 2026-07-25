import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:billing_baba/features/reports/utils/report_export_service.dart';
import 'package:billing_baba/features/reports/utils/report_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExpenseCategoryReportContent extends ConsumerWidget {
  const ExpenseCategoryReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(expenseByCategoryReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () =>
          ref.read(expenseByCategoryReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalExpense = rows.fold<double>(
          0,
          (sum, row) => sum + row.amount,
        );

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Expense Category Report',
            filename: 'expense-category-report',
            headers: const ['Expense Category', 'Category Type', 'Amount'],
            rows: [
              for (final row in rows)
                [
                  row.category,
                  'Direct Expense',
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
                  title: 'Expense Category Report',
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
                        title: 'Expense Category Report',
                        content: ReportExportService.toCsv(
                          headers: const [
                            'Expense Category',
                            'Category Type',
                            'Amount',
                          ],
                          rows: [
                            for (final row in rows)
                              [
                                row.category,
                                'Direct Expense',
                                formatReportCurrency(row.amount),
                              ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ReportCard(
                  backgroundColor: const Color(0xFFF5F7FA),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ReportFromToDateFilter(betweenLabel: 'From'),
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
                                'EXPENSE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: () =>
                                    context.push(AppRoutes.purchaseExpenses),
                                style: FilledButton.styleFrom(
                                  backgroundColor: reportActiveBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text(
                                  'Add Expense',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ReportTableArea(
                            child: rows.isEmpty
                              ? const Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ReportSyncScrollTable(
                                      headerChildren: [
                                        Expanded(
                                          child: ReportAlignedHeaderCell(
                                            label: 'EXPENSE CATEGORY',
                                          ),
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'CATEGORY TYPE',
                                          width: 180,
                                        ),
                                        ReportAlignedHeaderCell(
                                          label: 'AMOUNT',
                                          width: 140,
                                          alignment: Alignment.centerRight,
                                        ),
                                      ],
                                      rows: [],
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'No expense records found for the selected period.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ReportSyncScrollTable(
                                    headerChildren: const [
                                      Expanded(
                                        child: ReportAlignedHeaderCell(
                                          label: 'EXPENSE CATEGORY',
                                        ),
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'CATEGORY TYPE',
                                        width: 180,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'AMOUNT',
                                        width: 140,
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
                                                child: Text(rows[i].category),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                180,
                                                child: Text('Direct Expense'),
                                              ),
                                              ReportAlignedCell.fixed(
                                                140,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].amount,
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
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(fontSize: 14),
                                children: [
                                  const TextSpan(
                                    text: 'Total Expense: ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatReportCurrency(totalExpense),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: reportAddRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
