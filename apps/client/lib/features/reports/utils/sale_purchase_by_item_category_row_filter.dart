import 'package:billing_baba/features/reports/application/sale_purchase_by_item_category_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportCategoryAmountRow> applySalePurchaseByItemCategoryColumnFilters(
  List<ReportCategoryAmountRow> rows,
  SalePurchaseByItemCategoryColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.categoryColumnFilter != null &&
        !filters.categoryColumnFilter!.matches(row.category)) {
      return false;
    }
    if (filters.saleAmountColumnFilter != null &&
        !filters.saleAmountColumnFilter!.matches(row.saleAmount)) {
      return false;
    }
    if (filters.purchaseAmountColumnFilter != null &&
        !filters.purchaseAmountColumnFilter!.matches(row.purchaseAmount)) {
      return false;
    }
    return true;
  }).toList();
}
