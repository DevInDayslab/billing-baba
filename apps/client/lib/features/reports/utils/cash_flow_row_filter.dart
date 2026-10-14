import 'package:billing_baba/features/reports/application/cash_flow_column_filters_provider.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';

List<ReportCashFlowTableRow> applyCashFlowColumnFilters(
  List<ReportCashFlowTableRow> rows,
  CashFlowColumnFiltersState filters,
) {
  return rows.where((entry) {
    final row = entry.transaction;
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
    if (filters.moneyInColumnFilter != null &&
        !filters.moneyInColumnFilter!.matches(row.moneyIn)) {
      return false;
    }
    if (filters.moneyOutColumnFilter != null &&
        !filters.moneyOutColumnFilter!.matches(row.moneyOut)) {
      return false;
    }
    if (filters.runningBalanceColumnFilter != null &&
        !filters.runningBalanceColumnFilter!.matches(entry.runningBalance)) {
      return false;
    }
    return true;
  }).toList();
}
