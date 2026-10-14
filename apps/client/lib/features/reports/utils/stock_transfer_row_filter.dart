import 'package:billing_baba/features/reports/application/stock_transfer_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportStockTransferRow> applyStockTransferColumnFilters(
  List<ReportStockTransferRow> rows,
  StockTransferColumnFiltersState filters,
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
    if (filters.fromGodownColumnFilter != null &&
        !filters.fromGodownColumnFilter!.matches(row.fromGodown)) {
      return false;
    }
    if (filters.toGodownColumnFilter != null &&
        !filters.toGodownColumnFilter!.matches(row.toGodown)) {
      return false;
    }
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
      return false;
    }
    if (filters.quantityColumnFilter != null &&
        !filters.quantityColumnFilter!.matches(row.quantity)) {
      return false;
    }
    return true;
  }).toList();
}
