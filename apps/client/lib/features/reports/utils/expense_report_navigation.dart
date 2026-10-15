import 'package:billing_baba/features/reports/application/expense_column_filters_provider.dart';
import 'package:billing_baba/features/reports/application/report_filters_provider.dart';
import 'package:billing_baba/features/reports/application/reports_nav_intent_provider.dart';
import 'package:billing_baba/features/reports/models/expense_report_subsection.dart';
import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the line-item expense report filtered to [categoryId] (Vyapar-style drill-down).
void openExpenseReportForCategory(
  WidgetRef ref, {
  required String categoryId,
  required String categoryName,
}) {
  ref.read(expenseColumnFiltersProvider.notifier).reset();
  ref
      .read(expenseColumnFiltersProvider.notifier)
      .setCategoryColumnFilter(SelectColumnFilter(value: categoryName));
  ref.read(reportsNavIntentProvider.notifier).setIntent(
    ReportsNavIntent.expense(
      ExpenseReportSubSection.expense,
      categoryId: categoryId,
      categoryName: categoryName,
    ),
  );
}

/// Opens the expense report with search and optional category scope for an item row.
void openExpenseReportForItem(
  WidgetRef ref, {
  required String itemName,
  String? categoryId,
  String? categoryName,
}) {
  ref.read(expenseColumnFiltersProvider.notifier).reset();
  ref.read(reportFiltersProvider.notifier).setSearchQuery(itemName);
  if (categoryName != null && categoryName.isNotEmpty) {
    ref
        .read(expenseColumnFiltersProvider.notifier)
        .setCategoryColumnFilter(SelectColumnFilter(value: categoryName));
  }
  ref.read(reportsNavIntentProvider.notifier).setIntent(
    ReportsNavIntent.expense(
      ExpenseReportSubSection.expense,
      categoryId: categoryId,
      categoryName: categoryName,
    ),
  );
}
