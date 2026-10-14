import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/reports/application/all_parties_column_filters_provider.dart';

double _receivableAmount(PartyModel party) =>
    party.balance > 0 ? party.balance : 0;

double _payableAmount(PartyModel party) =>
    party.balance < 0 ? party.balance.abs() : 0;

double _creditLimitAmount(PartyModel party) =>
    double.tryParse(party.creditLimit) ?? 0;

List<PartyModel> applyAllPartiesColumnFilters(
  List<PartyModel> rows,
  AllPartiesColumnFiltersState filters,
) {
  return rows.where((party) {
    if (filters.partyNameColumnFilter != null &&
        !filters.partyNameColumnFilter!.matches(party.name)) {
      return false;
    }
    if (filters.emailColumnFilter != null &&
        !filters.emailColumnFilter!.matches(party.email)) {
      return false;
    }
    if (filters.phoneColumnFilter != null &&
        !filters.phoneColumnFilter!.matches(party.phone)) {
      return false;
    }
    if (filters.receivableColumnFilter != null &&
        !filters.receivableColumnFilter!.matches(_receivableAmount(party))) {
      return false;
    }
    if (filters.payableColumnFilter != null &&
        !filters.payableColumnFilter!.matches(_payableAmount(party))) {
      return false;
    }
    if (filters.creditLimitColumnFilter != null &&
        !filters.creditLimitColumnFilter!.matches(_creditLimitAmount(party))) {
      return false;
    }
    return true;
  }).toList();
}
