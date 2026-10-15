import 'package:billing_baba/features/reports/application/item_wise_profit_loss_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportItemWiseProfitLossRow> applyItemWiseProfitLossColumnFilters(
  List<ReportItemWiseProfitLossRow> rows,
  ItemWiseProfitLossColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
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
        !filters.profitColumnFilter!.matches(row.profit)) {
      return false;
    }
    return true;
  }).toList();
}
