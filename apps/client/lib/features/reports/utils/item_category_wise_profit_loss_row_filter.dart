import 'package:billing_baba/features/reports/application/item_category_wise_profit_loss_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

double categoryWiseProfitLoss(ReportCategoryAmountRow row) =>
    row.saleAmount - row.purchaseAmount;

List<ReportCategoryAmountRow> applyItemCategoryWiseProfitLossColumnFilters(
  List<ReportCategoryAmountRow> rows,
  ItemCategoryWiseProfitLossColumnFiltersState filters,
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
    if (filters.profitColumnFilter != null &&
        !filters.profitColumnFilter!.matches(categoryWiseProfitLoss(row))) {
      return false;
    }
    return true;
  }).toList();
}
