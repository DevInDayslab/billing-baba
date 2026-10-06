import 'package:billing_baba/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const partiesTabPartiesIndex = 0;
const partiesTabGroupsIndex = 1;
const partiesTabHiddenLedgerIndex = 2;

int partiesTabIndexForRoute(String location) {
  if (location.startsWith(AppRoutes.partyGroups)) {
    return partiesTabGroupsIndex;
  }
  if (location.startsWith(AppRoutes.partyHiddenLedger)) {
    return partiesTabHiddenLedgerIndex;
  }
  return partiesTabPartiesIndex;
}

String partiesRouteForTabIndex(int index) {
  switch (index) {
    case partiesTabGroupsIndex:
      return AppRoutes.partyGroups;
    case partiesTabHiddenLedgerIndex:
      return AppRoutes.partyHiddenLedger;
    default:
      return AppRoutes.partyDetails;
  }
}

final partiesTabIndexProvider = NotifierProvider<PartiesTabIndex, int>(
  PartiesTabIndex.new,
);

class PartiesTabIndex extends Notifier<int> {
  @override
  int build() => partiesTabPartiesIndex;

  int get tabIndex => state;
  set tabIndex(int index) => state = index;
}
