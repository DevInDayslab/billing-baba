import 'package:billing_baba/features/reports/application/bill_wise_profit_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportBillWiseProfitRow> applyBillWiseProfitColumnFilters(
  List<ReportBillWiseProfitRow> rows,
  BillWiseProfitColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.dateColumnFilter != null &&
        !filters.dateColumnFilter!.matches(row.date)) {
      return false;
    }
    if (filters.invoiceNoColumnFilter != null &&
        !filters.invoiceNoColumnFilter!.matches(row.invoiceNo)) {
      return false;
    }
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.partyName)) {
      return false;
    }
    if (filters.saleAmountColumnFilter != null &&
        !filters.saleAmountColumnFilter!.matches(row.saleAmount)) {
      return false;
    }
    if (filters.profitColumnFilter != null &&
        !filters.profitColumnFilter!.matches(row.profit)) {
      return false;
    }
    return true;
  }).toList();
}
