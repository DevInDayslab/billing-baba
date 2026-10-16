import 'package:billing_baba/features/parties/utils/walk_in_party.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_screen_tabs_provider.g.dart';

String saleScreenTabLabelForCart({
  required int posNumber,
  String? customerName,
}) {
  final customer = customerName?.trim();
  if (customer != null &&
      customer.isNotEmpty &&
      !isWalkInPartyName(customer)) {
    return customer;
  }
  return 'POS $posNumber';
}

class SaleScreenTab {
  const SaleScreenTab({
    required this.sessionKey,
    required this.label,
    required this.posNumber,
  });

  final String sessionKey;
  final String label;
  final int posNumber;
}

class SaleScreenTabsState {
  const SaleScreenTabsState({
    required this.tabs,
    required this.activeIndex,
  });

  final List<SaleScreenTab> tabs;
  final int activeIndex;

  SaleScreenTab get activeTab => tabs[activeIndex];

  SaleScreenTabsState copyWith({
    List<SaleScreenTab>? tabs,
    int? activeIndex,
  }) {
    return SaleScreenTabsState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

int _nextAvailablePosNumber(List<SaleScreenTab> tabs, {required int maxTabs}) {
  final used = tabs.map((tab) => tab.posNumber).toSet();
  for (var number = 1; number <= maxTabs; number++) {
    if (!used.contains(number)) {
      return number;
    }
  }
  return maxTabs;
}

String _sessionKeyForPosNumber(int posNumber) => 'sale_screen_tab_$posNumber';

@Riverpod(keepAlive: true)
class SaleScreenTabs extends _$SaleScreenTabs {
  static const maxTabs = 10;

  bool get canAddTab => state.tabs.length < maxTabs;

  @override
  SaleScreenTabsState build() {
    const posNumber = 1;
    return SaleScreenTabsState(
      tabs: [
        SaleScreenTab(
          sessionKey: _sessionKeyForPosNumber(posNumber),
          label: 'POS $posNumber',
          posNumber: posNumber,
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
    final posNumber = _nextAvailablePosNumber(state.tabs, maxTabs: maxTabs);
    final newTab = SaleScreenTab(
      sessionKey: _sessionKeyForPosNumber(posNumber),
      label: 'POS $posNumber',
      posNumber: posNumber,
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
    tabs[index] = SaleScreenTab(
      sessionKey: tab.sessionKey,
      label: label,
      posNumber: tab.posNumber,
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
