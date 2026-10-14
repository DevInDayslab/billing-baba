import 'package:billing_baba/features/reports/application/stock_detail_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportStockDetailRow> applyStockDetailColumnFilters(
  List<ReportStockDetailRow> rows,
  StockDetailColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
      return false;
    }
    if (filters.openingColumnFilter != null &&
        !filters.openingColumnFilter!.matches(row.openingQty)) {
      return false;
    }
    if (filters.inColumnFilter != null &&
        !filters.inColumnFilter!.matches(row.inQty)) {
      return false;
    }
    if (filters.outColumnFilter != null &&
        !filters.outColumnFilter!.matches(row.outQty)) {
      return false;
    }
    if (filters.closingColumnFilter != null &&
        !filters.closingColumnFilter!.matches(row.closingQty)) {
      return false;
    }
    return true;
  }).toList();
}
