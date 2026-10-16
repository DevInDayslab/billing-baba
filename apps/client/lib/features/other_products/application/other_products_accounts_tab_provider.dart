import 'package:billing_baba/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const otherProductsAccountsTabOtherIncomeIndex = 0;
const otherProductsAccountsTabCashAndBankIndex = 1;
const otherProductsAccountsTabLoanAccountsIndex = 2;

int otherProductsAccountsTabIndexForRoute(String location) {
  if (location == AppRoutes.saleCashAndBank) {
    return otherProductsAccountsTabCashAndBankIndex;
  }
  if (location == AppRoutes.loanAccounts ||
      location.startsWith('${AppRoutes.loanAccountDetail}/') ||
      location == AppRoutes.addLoanAccount ||
      location.startsWith('${AppRoutes.editLoanAccount}/') ||
      location == AppRoutes.addLoanTransaction) {
    return otherProductsAccountsTabLoanAccountsIndex;
  }
  return otherProductsAccountsTabOtherIncomeIndex;
}

String otherProductsAccountsRouteForTabIndex(int index) {
  switch (index) {
    case otherProductsAccountsTabCashAndBankIndex:
      return AppRoutes.saleCashAndBank;
    case otherProductsAccountsTabLoanAccountsIndex:
      return AppRoutes.loanAccounts;
    default:
      return AppRoutes.otherIncome;
  }
}

final otherProductsAccountsTabIndexProvider =
    NotifierProvider<OtherProductsAccountsTabIndex, int>(
  OtherProductsAccountsTabIndex.new,
);

class OtherProductsAccountsTabIndex extends Notifier<int> {
  @override
  int build() => otherProductsAccountsTabOtherIncomeIndex;

  int get tabIndex => state;
  set tabIndex(int index) => state = index;
}
