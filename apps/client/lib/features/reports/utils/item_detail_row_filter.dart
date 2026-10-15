import 'package:billing_baba/features/reports/application/item_detail_column_filters_provider.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';

List<ReportItemDetailTableRow> applyItemDetailColumnFilters(
  List<ReportItemDetailTableRow> rows,
  ItemDetailColumnFiltersState filters,
) {
  return rows.where((entry) {
    final row = entry.row;
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
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.partyName)) {
      return false;
    }
    if (filters.quantityColumnFilter != null &&
        !filters.quantityColumnFilter!.matches(row.quantity)) {
      return false;
    }
    if (filters.priceColumnFilter != null &&
        !filters.priceColumnFilter!.matches(row.price)) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(row.amount)) {
      return false;
    }
    if (filters.closingQtyColumnFilter != null &&
        !filters.closingQtyColumnFilter!.matches(entry.closingQty)) {
      return false;
    }
    return true;
  }).toList();
}
