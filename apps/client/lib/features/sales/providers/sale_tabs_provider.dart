import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_tabs_provider.g.dart';

String saleTabLabelForForm({
  required int saleNumber,
  String? billingName,
}) {
  final party = billingName?.trim();
  if (party != null && party.isNotEmpty) {
    return party;
  }
  return 'Sale $saleNumber';
}

class SaleTab {
  const SaleTab({
    required this.sessionKey,
    required this.label,
    required this.saleNumber,
    this.documentId,
  });

  final String sessionKey;
  final String label;
  final int saleNumber;
  final String? documentId;
}

class SaleTabsState {
  const SaleTabsState({
    required this.tabs,
    required this.activeIndex,
  });

  final List<SaleTab> tabs;
  final int activeIndex;

  SaleTab get activeTab => tabs[activeIndex];

  SaleTabsState copyWith({
    List<SaleTab>? tabs,
    int? activeIndex,
  }) {
    return SaleTabsState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

int _tabCounter = 0;

int _nextSaleNumber() {
  _tabCounter += 1;
  return _tabCounter;
}

String _sessionKeyForSaleNumber(int saleNumber) => 'sale_tab_$saleNumber';

@riverpod
class SaleTabs extends _$SaleTabs {
  static const maxTabs = 10;

  bool get canAddTab => state.tabs.length < maxTabs;

  @override
  SaleTabsState build({String? initialDocumentId}) {
    final saleNumber = _nextSaleNumber();
    final sessionKey =
        initialDocumentId ?? _sessionKeyForSaleNumber(saleNumber);
    return SaleTabsState(
      tabs: [
        SaleTab(
          sessionKey: sessionKey,
          label: 'Sale $saleNumber',
          saleNumber: saleNumber,
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
    final saleNumber = _nextSaleNumber();
    final newTab = SaleTab(
      sessionKey: _sessionKeyForSaleNumber(saleNumber),
      label: 'Sale $saleNumber',
      saleNumber: saleNumber,
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
    tabs[index] = SaleTab(
      sessionKey: tab.sessionKey,
      label: label,
      saleNumber: tab.saleNumber,
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
