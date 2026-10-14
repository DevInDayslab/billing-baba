import 'package:billing_baba/features/reports/application/expense_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/expense_export.dart';

List<ReportExpenseRow> applyExpenseColumnFilters(
  List<ReportExpenseRow> rows,
  ExpenseColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(row.date)) {
      return false;
    }
    if (filters.expenseNoColumnFilter != null &&
        !filters.expenseNoColumnFilter!.matches(row.expenseNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.partyName)) {
      return false;
    }
    if (filters.categoryColumnFilter != null &&
        !filters.categoryColumnFilter!.matches(row.category)) {
      return false;
    }
    if (filters.paymentTypeColumnFilter != null &&
        !filters.paymentTypeColumnFilter!.matches(row.paymentType ?? '')) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(row.amount)) {
      return false;
    }
    if (filters.balanceDueColumnFilter != null &&
        !filters.balanceDueColumnFilter!.matches(row.balanceDue)) {
      return false;
    }
    if (filters.dueDateColumnFilter != null) {
      if (row.dueDate == null) return false;
      if (!filters.dueDateColumnFilter!.matches(row.dueDate!)) {
        return false;
      }
    }
    if (filters.statusColumnFilter != null &&
        !filters.statusColumnFilter!.matches(
          expenseReportStatusLabel(row.status),
        )) {
      return false;
    }
    return true;
  }).toList();
}
