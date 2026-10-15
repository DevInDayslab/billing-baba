import 'package:billing_baba/features/reports/application/sale_purchase_by_party_column_filters_provider.dart';
import 'package:billing_baba/features/reports/utils/report_transaction_table_shared.dart';

List<ReportSalePurchaseByPartyTableRow> applySalePurchaseByPartyColumnFilters(
  List<ReportSalePurchaseByPartyTableRow> rows,
  SalePurchaseByPartyColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.row.partyName)) {
      return false;
    }
    if (filters.saleAmountColumnFilter != null &&
        !filters.saleAmountColumnFilter!.matches(row.row.saleAmount)) {
      return false;
    }
    if (filters.purchaseAmountColumnFilter != null &&
        !filters.purchaseAmountColumnFilter!.matches(row.row.purchaseAmount)) {
      return false;
    }

    final balance = row.party?.balance ?? 0;
    final receivable = balance > 0 ? balance : 0.0;
    final payable = balance < 0 ? balance.abs() : 0.0;

    if (filters.receivableColumnFilter != null &&
        !filters.receivableColumnFilter!.matches(receivable)) {
      return false;
    }
    if (filters.payableColumnFilter != null &&
        !filters.payableColumnFilter!.matches(payable)) {
      return false;
    }
    return true;
  }).toList();
}
