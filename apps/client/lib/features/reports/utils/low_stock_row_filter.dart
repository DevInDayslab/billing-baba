import 'package:billing_baba/features/reports/application/low_stock_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportLowStockRow> applyLowStockColumnFilters(
  List<ReportLowStockRow> rows,
  LowStockColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
      return false;
    }
    if (filters.minStockColumnFilter != null &&
        !filters.minStockColumnFilter!.matches(row.minStock)) {
      return false;
    }
    if (filters.currentStockColumnFilter != null &&
        !filters.currentStockColumnFilter!.matches(row.currentStock)) {
      return false;
    }
    if (filters.shortageColumnFilter != null &&
        !filters.shortageColumnFilter!.matches(row.shortage)) {
      return false;
    }
    return true;
  }).toList();
}
