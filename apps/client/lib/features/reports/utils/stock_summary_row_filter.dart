import 'package:billing_baba/features/reports/application/stock_summary_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportStockSummaryRow> applyStockSummaryColumnFilters(
  List<ReportStockSummaryRow> rows,
  StockSummaryColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
      return false;
    }
    if (filters.salePriceColumnFilter != null &&
        !filters.salePriceColumnFilter!.matches(row.salePrice)) {
      return false;
    }
    if (filters.purchasePriceColumnFilter != null &&
        !filters.purchasePriceColumnFilter!.matches(row.purchasePrice)) {
      return false;
    }
    if (filters.stockQtyColumnFilter != null &&
        !filters.stockQtyColumnFilter!.matches(row.stockQty)) {
      return false;
    }
    if (filters.stockValueColumnFilter != null &&
        !filters.stockValueColumnFilter!.matches(row.stockValue)) {
      return false;
    }
    return true;
  }).toList();
}
