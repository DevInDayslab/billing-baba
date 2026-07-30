import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_aligned_table.dart';
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
import 'package:go_router/go_router.dart';

class ExpenseReportContent extends ConsumerWidget {
  const ExpenseReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(expensesReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(expensesReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalAmount = report.totalAmount;

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Expense',
            filename: 'expense-report',
            headers: const [
              'Date',
              'Exp No',
              'Party',
              'Category',
              'Payment Type',
              'Amount',
              'Balance Due',
              'Due Date',
              'Status',
            ],
            rows: [
              for (final row in rows)
                [
                  formatReportDate(row.date),
                  row.expenseNo,
                  row.partyName,
                  row.category,
                  '-',
                  formatReportCurrency(row.amount),
                  '-',
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
                  title: 'Expense',
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
                        title: 'Expense',
                        content: ReportExportService.toCsv(
                          headers: const [
                            'Date',
                            'Exp No',
                            'Party',
                            'Category',
                            'Payment Type',
                            'Amount',
                            'Balance Due',
                            'Due Date',
                            'Status',
                          ],
                          rows: [
                            for (final row in rows)
                              [
                                formatReportDate(row.date),
                                row.expenseNo,
                                row.partyName,
                                row.category,
                                '-',
                                formatReportCurrency(row.amount),
                                '-',
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
                                  hintText: 'Search expenses...',
                                  onChanged: ref
                                      .read(reportFiltersProvider.notifier)
                                      .setSearchQuery,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
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
                                          ReportAlignedHeaderCell(
                                            label: 'DATE',
                                            width: 100,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'EXP NO',
                                            width: 100,
                                          ),
                                          Expanded(
                                            child: ReportAlignedHeaderCell(
                                              label: 'PARTY',
                                            ),
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'CATEGORY',
                                            width: 110,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'PAYMENT TYPE',
                                            width: 120,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'AMOUNT',
                                            width: 100,
                                            alignment: Alignment.centerRight,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'BALANCE DUE',
                                            width: 110,
                                            alignment: Alignment.centerRight,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'DUE DATE',
                                            width: 100,
                                          ),
                                          ReportAlignedHeaderCell(
                                            label: 'STATUS',
                                            width: 90,
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
                                      ReportAlignedHeaderCell(
                                        label: 'DATE',
                                        width: 100,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'EXP NO',
                                        width: 100,
                                      ),
                                      Expanded(
                                        child: ReportAlignedHeaderCell(
                                          label: 'PARTY',
                                        ),
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'CATEGORY',
                                        width: 110,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'PAYMENT TYPE',
                                        width: 120,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'AMOUNT',
                                        width: 100,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'BALANCE DUE',
                                        width: 110,
                                        alignment: Alignment.centerRight,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'DUE DATE',
                                        width: 100,
                                      ),
                                      ReportAlignedHeaderCell(
                                        label: 'STATUS',
                                        width: 90,
                                      ),
                                    ],
                                    rows: [
                                      for (var i = 0; i < rows.length; i++)
                                        ReportAlignedRowStrip(
                                          index: i,
                                          child: ReportAlignedDataRow(
                                            cells: [
                                              ReportAlignedCell.fixed(
                                                100,
                                                child: Text(
                                                  formatReportDate(
                                                    rows[i].date,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                100,
                                                child: Text(rows[i].expenseNo),
                                              ),
                                              ReportAlignedCell.flex(
                                                child: Text(rows[i].partyName),
                                              ),
                                              ReportAlignedCell.fixed(
                                                110,
                                                child: Text(rows[i].category),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                120,
                                                child: Text('-'),
                                              ),
                                              ReportAlignedCell.fixed(
                                                100,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  formatReportCurrency(
                                                    rows[i].amount,
                                                  ),
                                                ),
                                              ),
                                              const ReportAlignedCell.fixed(
                                                110,
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text('-'),
                                              ),
                                              ReportAlignedCell.fixed(
                                                100,
                                                child: Text(
                                                  formatReportDate(
                                                    rows[i].dueDate,
                                                  ),
                                                ),
                                              ),
                                              ReportAlignedCell.fixed(
                                                90,
                                                child: Text(rows[i].status),
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
                                    text: 'Total Amount: ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatReportCurrency(totalAmount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ReportPaginationBar(
                          page: report.meta.page,
                          totalPages: report.meta.totalPages,
                          onPrevious: report.meta.page > 1
                              ? () => ref
                                    .read(expensesReportProvider.notifier)
                                    .goToPage(report.meta.page - 1)
                              : null,
                          onNext: report.meta.page < report.meta.totalPages
                              ? () => ref
                                    .read(expensesReportProvider.notifier)
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
