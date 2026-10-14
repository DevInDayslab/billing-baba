import 'package:billing_baba/features/reports/application/sale_purchase_orders_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/report_order_filter_utils.dart';

List<ReportOrderRow> applySalePurchaseOrdersColumnFilters(
  List<ReportOrderRow> rows,
  SalePurchaseOrdersColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(row.date)) {
      return false;
    }
    if (filters.orderNoColumnFilter != null &&
        !filters.orderNoColumnFilter!.matches(row.orderNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.partyName)) {
      return false;
    }
    if (filters.dueDateColumnFilter != null &&
        !filters.dueDateColumnFilter!.matches(row.dueDate)) {
      return false;
    }
    if (filters.statusColumnFilter != null &&
        !filters.statusColumnFilter!.matches(
          salePurchaseOrderStatusLabel(row.status),
        )) {
      return false;
    }
    if (filters.typeColumnFilter != null &&
        !filters.typeColumnFilter!.matches(
          salePurchaseOrderRowTypeLabel(row.type),
        )) {
      return false;
    }
    if (filters.totalColumnFilter != null &&
        !filters.totalColumnFilter!.matches(row.amount)) {
      return false;
    }
    if (filters.advanceColumnFilter != null &&
        !filters.advanceColumnFilter!.matches(row.advance)) {
      return false;
    }
    if (filters.balanceColumnFilter != null &&
        !filters.balanceColumnFilter!.matches(row.balance)) {
      return false;
    }
    return true;
  }).toList();
}
