import 'dart:async';

import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/models/held_bill.dart';
import 'package:billing_baba/features/sale_screen/application/sale_screen_tabs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool isSaleScreenCartSessionKey(String sessionKey) =>
    sessionKey.startsWith('sale_screen_tab_');

/// Picks the active tab when empty; otherwise opens a new sale-screen tab.
String? allocateSaleScreenSessionForHeldBillResume(WidgetRef ref) {
  final tabsState = ref.read(saleScreenTabsProvider);
  final activeKey = tabsState.activeTab.sessionKey;
  final activeCart = ref.read(posCartProvider(sessionKey: activeKey));
  if (activeCart.items.isEmpty) {
    return activeKey;
  }

  final tabsNotifier = ref.read(saleScreenTabsProvider.notifier);
  if (!tabsNotifier.canAddTab) {
    return null;
  }
  tabsNotifier.addTab();
  return ref.read(saleScreenTabsProvider).activeTab.sessionKey;
}

void resumeHeldBillOnSaleScreenSession(
  WidgetRef ref, {
  required String sessionKey,
  required HeldBill bill,
}) {
  ref.read(posCartProvider(sessionKey: sessionKey).notifier).resumeBill(bill);
  syncSaleScreenHeldBills(ref);
  updateSaleScreenTabLabelForSession(ref, sessionKey);
}

void syncSaleScreenHeldBills(WidgetRef ref) {
  final tabs = ref.read(saleScreenTabsProvider).tabs;
  for (final tab in tabs) {
    if (!isSaleScreenCartSessionKey(tab.sessionKey)) continue;
    unawaited(
      ref
          .read(posCartProvider(sessionKey: tab.sessionKey).notifier)
          .refreshHeldBills(),
    );
  }
}

void updateSaleScreenTabLabelForSession(WidgetRef ref, String sessionKey) {
  final tabsState = ref.read(saleScreenTabsProvider);
  final index = tabsState.tabs.indexWhere((tab) => tab.sessionKey == sessionKey);
  if (index < 0) return;

  final tab = tabsState.tabs[index];
  final cart = ref.read(posCartProvider(sessionKey: sessionKey));
  ref.read(saleScreenTabsProvider.notifier).updateTabLabel(
    index,
    saleScreenTabLabelForCart(
      posNumber: tab.posNumber,
      customerName: cart.customerName,
    ),
  );
}
