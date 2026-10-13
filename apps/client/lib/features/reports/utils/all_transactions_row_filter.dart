import 'package:billing_baba/features/reports/application/all_transactions_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportTransactionRow> applyAllTransactionsColumnFilters(
  List<ReportTransactionRow> rows,
  AllTransactionsColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(row.date)) {
      return false;
    }
    if (filters.refNoColumnFilter != null &&
        !filters.refNoColumnFilter!.matches(row.refNo)) {
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
    if (filters.typeColumnFilter != null &&
        !filters.typeColumnFilter!.matches(row.type)) {
      return false;
    }
    if (filters.totalColumnFilter != null &&
        !filters.totalColumnFilter!.matches(row.total)) {
      return false;
    }
    if (filters.receivedColumnFilter != null &&
        !filters.receivedColumnFilter!.matches(row.received)) {
      return false;
    }
    if (filters.balanceColumnFilter != null &&
        !filters.balanceColumnFilter!.matches(row.balance)) {
      return false;
    }
    if (filters.dueDateColumnFilter != null) {
      if (row.dueDate == null) return false;
      if (!filters.dueDateColumnFilter!.matches(row.dueDate!)) {
        return false;
      }
    }
    if (filters.statusColumnFilter != null &&
        !filters.statusColumnFilter!.matches(row.status)) {
      return false;
    }
    return true;
  }).toList();
}
