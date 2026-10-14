import 'package:billing_baba/features/reports/application/item_report_by_party_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportItemByPartyRow> applyItemReportByPartyColumnFilters(
  List<ReportItemByPartyRow> rows,
  ItemReportByPartyColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.partyName)) {
      return false;
    }
    if (filters.quantityColumnFilter != null &&
        !filters.quantityColumnFilter!.matches(row.quantity)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(row.amount)) {
      return false;
    }
    return true;
  }).toList();
}
