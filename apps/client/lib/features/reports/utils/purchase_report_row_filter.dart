import 'package:billing_baba/features/reports/application/purchase_report_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';
import 'package:billing_baba/features/reports/utils/sale_report_row_filter.dart';

List<ReportPurchaseRow> applyPurchaseReportColumnFilters(
  List<ReportPurchaseRow> rows,
  PurchaseReportColumnFiltersState filters,
) {
  return rows.where((purchase) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(purchase.date)) {
      return false;
    }
    if (filters.invoiceNoColumnFilter != null &&
        !filters.invoiceNoColumnFilter!.matches(purchase.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(purchase.partyName)) {
      return false;
    }
    if (filters.paymentTypeColumnFilter != null &&
        !filters.paymentTypeColumnFilter!.matches(purchase.paymentType)) {
      return false;
    }
    if (filters.statusColumnFilter != null &&
        !filters.statusColumnFilter!.matches(
          saleReportStatusLabel(purchase.status),
        )) {
      return false;
    }
    if (filters.amountColumnFilter != null &&
        !filters.amountColumnFilter!.matches(purchase.amount)) {
      return false;
    }
    if (filters.balanceColumnFilter != null &&
        !filters.balanceColumnFilter!.matches(purchase.balance)) {
      return false;
    }
    return true;
  }).toList();
}
