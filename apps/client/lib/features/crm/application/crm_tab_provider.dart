import 'package:billing_baba/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const crmTabLeadsIndex = 0;
const crmTabContactsIndex = 1;
const crmTabDealsIndex = 2;

int crmTabIndexForRoute(String location) {
  if (location.startsWith(AppRoutes.crmContacts)) {
    return crmTabContactsIndex;
  }
  if (location.startsWith(AppRoutes.crmDeals)) {
    return crmTabDealsIndex;
  }
  return crmTabLeadsIndex;
}

String crmRouteForTabIndex(int index) {
  switch (index) {
    case crmTabContactsIndex:
      return AppRoutes.crmContacts;
    case crmTabDealsIndex:
      return AppRoutes.crmDeals;
    default:
      return AppRoutes.crmLeads;
  }
}

final crmTabIndexProvider = NotifierProvider<CrmTabIndex, int>(CrmTabIndex.new);

class CrmTabIndex extends Notifier<int> {
  @override
  int build() => crmTabLeadsIndex;

  int get tabIndex => state;
  set tabIndex(int index) => state = index;
}
