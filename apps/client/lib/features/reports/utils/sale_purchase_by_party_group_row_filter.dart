import 'package:billing_baba/features/reports/application/sale_purchase_by_party_group_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportSalePurchaseByPartyGroupRow> applySalePurchaseByPartyGroupColumnFilters(
  List<ReportSalePurchaseByPartyGroupRow> rows,
  SalePurchaseByPartyGroupColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.partyGroupColumnFilter != null &&
        !filters.partyGroupColumnFilter!.matches(row.partyGroup)) {
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
    if (filters.purchaseAmountColumnFilter != null &&
        !filters.purchaseAmountColumnFilter!.matches(row.purchaseAmount)) {
      return false;
    }
    return true;
  }).toList();
}
