import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_order_tabs_provider.g.dart';

String saleOrderTabLabelForForm({
  required int orderNumber,
  String? partyName,
}) {
  final party = partyName?.trim();
  if (party != null && party.isNotEmpty) {
    return party;
  }
  return 'Sale Order #$orderNumber';
}

class SaleOrderTab {
  const SaleOrderTab({
    required this.sessionKey,
    required this.label,
    required this.orderNumber,
    this.documentId,
  });

  final String sessionKey;
  final String label;
  final int orderNumber;
  final String? documentId;
}

class SaleOrderTabsState {
  const SaleOrderTabsState({
    required this.tabs,
    required this.activeIndex,
  });

  final List<SaleOrderTab> tabs;
  final int activeIndex;

  SaleOrderTab get activeTab => tabs[activeIndex];

  SaleOrderTabsState copyWith({
    List<SaleOrderTab>? tabs,
    int? activeIndex,
  }) {
    return SaleOrderTabsState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

int _tabCounter = 0;

int _nextOrderNumber() {
  _tabCounter += 1;
  return _tabCounter;
}

String _sessionKeyForOrderNumber(int orderNumber) =>
    'sale_order_tab_$orderNumber';

@riverpod
class SaleOrderTabs extends _$SaleOrderTabs {
  static const maxTabs = 10;

  bool get canAddTab => state.tabs.length < maxTabs;

  @override
  SaleOrderTabsState build({String? initialDocumentId}) {
    final orderNumber = _nextOrderNumber();
    final sessionKey =
        initialDocumentId ?? _sessionKeyForOrderNumber(orderNumber);
    return SaleOrderTabsState(
      tabs: [
        SaleOrderTab(
          sessionKey: sessionKey,
          label: 'Sale Order #$orderNumber',
          orderNumber: orderNumber,
          documentId: initialDocumentId,
        ),
      ],
      activeIndex: 0,
    );
  }

  void selectTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;
    state = state.copyWith(activeIndex: index);
  }

  void addTab() {
    if (!canAddTab) return;
    final orderNumber = _nextOrderNumber();
    final newTab = SaleOrderTab(
      sessionKey: _sessionKeyForOrderNumber(orderNumber),
      label: 'Sale Order #$orderNumber',
      orderNumber: orderNumber,
    );
    state = state.copyWith(
      tabs: [...state.tabs, newTab],
      activeIndex: state.tabs.length,
    );
  }

  void updateTabLabel(int index, String label) {
    if (index < 0 || index >= state.tabs.length) return;
    final tab = state.tabs[index];
    if (tab.label == label) return;
    final tabs = [...state.tabs];
    tabs[index] = SaleOrderTab(
      sessionKey: tab.sessionKey,
      label: label,
      orderNumber: tab.orderNumber,
      documentId: tab.documentId,
    );
    state = state.copyWith(tabs: tabs);
  }

  void closeTab(int index) {
    if (state.tabs.length <= 1) return;
    final tabs = [...state.tabs]..removeAt(index);
    var activeIndex = state.activeIndex;
    if (index < activeIndex) {
      activeIndex -= 1;
    } else if (index == activeIndex) {
      activeIndex = activeIndex.clamp(0, tabs.length - 1);
    }
    state = state.copyWith(tabs: tabs, activeIndex: activeIndex);
  }
}
