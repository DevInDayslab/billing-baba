import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/expense/expense_category_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/utils/expense_category_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            headers: expenseCategoryExportHeaders,
            rows: [for (final row in rows) expenseCategoryExportRow(row)],
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Expense Category Report',
            filename: 'expense-category-report',
            headers: expenseCategoryExportHeaders,
            rows: [for (final row in rows) expenseCategoryExportRow(row)],
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
                      label: 'Excel Report',
                      icon: Icons.table_chart_outlined,
                      onTap: exportCsv,
                    ),
                    ReportTextActionButton(
                      label: 'Print',
                      icon: Icons.print_outlined,
                      onTap: exportPrint,
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
                  child: ExpenseCategoryTransactionsTable(
                    rows: rows,
                    totalAmount: totalExpense,
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
