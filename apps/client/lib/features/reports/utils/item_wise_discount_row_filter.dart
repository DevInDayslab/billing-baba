import 'package:billing_baba/features/reports/application/item_wise_discount_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportItemDiscountRow> applyItemWiseDiscountColumnFilters(
  List<ReportItemDiscountRow> rows,
  ItemWiseDiscountColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.itemNameColumnFilter != null &&
        !filters.itemNameColumnFilter!.matches(row.itemName)) {
      return false;
    }
    if (filters.saleQtyColumnFilter != null &&
        !filters.saleQtyColumnFilter!.matches(row.saleQty)) {
      return false;
    }
    if (filters.discountAmountColumnFilter != null &&
        !filters.discountAmountColumnFilter!.matches(row.discountAmount)) {
      return false;
    }
    if (filters.discountPercentColumnFilter != null &&
        !filters.discountPercentColumnFilter!.matches(row.discountPercent)) {
      return false;
    }
    return true;
  }).toList();
}
