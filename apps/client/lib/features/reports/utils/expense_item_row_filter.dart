import 'package:billing_baba/features/reports/application/expense_item_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportExpenseItemRow> applyExpenseItemColumnFilters(
  List<ReportExpenseItemRow> rows,
  ExpenseItemColumnFiltersState filters,
  String searchQuery,
) {
  final query = searchQuery.trim().toLowerCase();

  return rows.where((row) {
    if (query.isNotEmpty) {
      final matchesSearch =
          row.itemName.toLowerCase().contains(query) ||
          row.category.toLowerCase().contains(query);
      if (!matchesSearch) return false;
    }
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
      return false;
    }
    if (filters.categoryColumnFilter != null &&
        !filters.categoryColumnFilter!.matches(row.category)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(row.amount)) {
      return false;
    }
    return true;
  }).toList();
}
