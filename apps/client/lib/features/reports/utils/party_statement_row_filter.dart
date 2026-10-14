import 'package:billing_baba/features/reports/application/party_statement_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportPartyStatementEntry> applyPartyStatementColumnFilters(
  List<ReportPartyStatementEntry> rows,
  PartyStatementColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(row.date)) {
      return false;
    }
    if (filters.typeColumnFilter != null &&
        !filters.typeColumnFilter!.matches(row.type)) {
      return false;
    }
    if (filters.refNoColumnFilter != null &&
        !filters.refNoColumnFilter!.matches(row.refNo)) {
      return false;
    }
    if (filters.totalColumnFilter != null &&
        !filters.totalColumnFilter!.matches(row.total)) {
      return false;
    }
    if (filters.balanceColumnFilter != null &&
        !filters.balanceColumnFilter!.matches(row.balance)) {
      return false;
    }
    return true;
  }).toList();
}
