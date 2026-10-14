import 'package:billing_baba/features/reports/application/day_book_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportTransactionRow> applyDayBookColumnFilters(
  List<ReportTransactionRow> rows,
  DayBookColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.partyName)) {
      return false;
    }
    if (filters.refNoColumnFilter != null &&
        !filters.refNoColumnFilter!.matches(row.refNo)) {
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
    if (filters.moneyInColumnFilter != null &&
        !filters.moneyInColumnFilter!.matches(row.moneyIn)) {
      return false;
    }
    if (filters.moneyOutColumnFilter != null &&
        !filters.moneyOutColumnFilter!.matches(row.moneyOut)) {
      return false;
    }
    return true;
  }).toList();
}
