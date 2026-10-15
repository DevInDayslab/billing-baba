import 'package:billing_baba/features/reports/application/party_wise_profit_loss_column_filters_provider.dart';
import 'package:billing_baba/features/reports/models/report_models.dart';

List<ReportPartyWiseProfitLossRow> applyPartyWiseProfitLossColumnFilters(
  List<ReportPartyWiseProfitLossRow> rows,
  PartyWiseProfitLossColumnFiltersState filters,
) {
  return rows.where((row) {
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(row.partyName)) {
      return false;
    }
    if (filters.phoneColumnFilter != null &&
        !filters.phoneColumnFilter!.matches(row.phone)) {
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
