import 'package:billing_baba/features/reports/application/expense_category_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportExpenseCategoryRow> applyExpenseCategoryColumnFilters(
  List<ReportExpenseCategoryRow> rows,
  ExpenseCategoryColumnFiltersState filters,
  String searchQuery,
) {
  final query = searchQuery.trim().toLowerCase();

  return rows.where((row) {
    if (query.isNotEmpty) {
      final matchesSearch =
          row.category.toLowerCase().contains(query) ||
          row.categoryTypeLabel.toLowerCase().contains(query);
      if (!matchesSearch) return false;
    }
    if (filters.categoryColumnFilter != null &&
        !filters.categoryColumnFilter!.matches(row.category)) {
      return false;
    }
    if (filters.categoryTypeColumnFilter != null &&
        !filters.categoryTypeColumnFilter!.matches(row.categoryTypeLabel)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(row.amount)) {
      return false;
    }
    return true;
  }).toList();
}
