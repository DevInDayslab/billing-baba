import 'package:billing_baba/features/reports/application/party_report_by_item_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportPartyByItemRow> applyPartyReportByItemColumnFilters(
  List<ReportPartyByItemRow> rows,
  PartyReportByItemColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.partyName)) {
      return false;
    }
    if (filters.saleQuantityColumnFilter != null &&
        !filters.saleQuantityColumnFilter!.matches(row.saleQuantity)) {
      return false;
    }
    if (filters.saleAmountColumnFilter != null &&
        !filters.saleAmountColumnFilter!.matches(row.saleAmount)) {
      return false;
    }
    if (filters.purchaseQuantityColumnFilter != null &&
        !filters.purchaseQuantityColumnFilter!.matches(row.purchaseQuantity)) {
      return false;
    }
    if (filters.purchaseAmountColumnFilter != null &&
        !filters.purchaseAmountColumnFilter!.matches(row.purchaseAmount)) {
      return false;
    }
    return true;
  }).toList();
}
