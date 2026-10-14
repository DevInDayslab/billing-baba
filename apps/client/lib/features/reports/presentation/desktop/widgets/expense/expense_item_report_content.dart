import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/reports/application/report_providers.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/expense/expense_item_transactions_table.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_async_body.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_card.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_date_widgets.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_export_actions.dart';
import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_responsive_widgets.dart';
import 'package:billing_baba/features/reports/utils/expense_item_export.dart';
import 'package:billing_baba/features/reports/utils/report_export_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseItemReportContent extends ConsumerWidget {
  const ExpenseItemReportContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(expenseByItemReportProvider);

    return ReportAsyncBody(
      value: reportAsync,
      onRetry: () => ref.read(expenseByItemReportProvider.notifier).refresh(),
      data: (report) {
        final rows = report.rows;
        final totalExpense = rows.fold<double>(
          0,
          (sum, row) => sum + row.amount,
        );

        void exportCsv() {
          reportExportTable(
            context: context,
            title: 'Expense Item Report',
            filename: 'expense-item-report',
            headers: expenseItemExportHeaders,
            rows: [for (final row in rows) expenseItemExportRow(row)],
          );
        }

        void exportPrint() {
          reportPrintTable(
            context: context,
            title: 'Expense Item Report',
            filename: 'expense-item-report',
            headers: expenseItemExportHeaders,
            rows: [for (final row in rows) expenseItemExportRow(row)],
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
                  title: 'Expense Item Report',
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
                  child: ExpenseItemTransactionsTable(
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
