import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_fa_tabs_provider.g.dart';

String saleFaTabLabelForForm({
  required int saleFaNumber,
  String? partyName,
}) {
  final party = partyName?.trim();
  if (party != null && party.isNotEmpty) {
    return party;
  }
  return 'Sale FA #$saleFaNumber';
}

class SaleFaTab {
  const SaleFaTab({
    required this.sessionKey,
    required this.label,
    required this.saleFaNumber,
    this.batchId,
  });

  final String sessionKey;
  final String label;
  final int saleFaNumber;
  final String? batchId;
}

class SaleFaTabsState {
  const SaleFaTabsState({
    required this.tabs,
    required this.activeIndex,
  });

  final List<SaleFaTab> tabs;
  final int activeIndex;

  SaleFaTab get activeTab => tabs[activeIndex];

  SaleFaTabsState copyWith({
    List<SaleFaTab>? tabs,
    int? activeIndex,
  }) {
    return SaleFaTabsState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

int _tabCounter = 0;

int _nextSaleFaNumber() {
  _tabCounter += 1;
  return _tabCounter;
}

String _sessionKeyForSaleFaNumber(int saleFaNumber) =>
    'sale_fa_tab_$saleFaNumber';

@riverpod
class SaleFaTabs extends _$SaleFaTabs {
  static const maxTabs = 10;

  bool get canAddTab => state.tabs.length < maxTabs;

  @override
  SaleFaTabsState build({String? initialBatchId}) {
    final saleFaNumber = _nextSaleFaNumber();
    final sessionKey =
        initialBatchId ?? _sessionKeyForSaleFaNumber(saleFaNumber);
    return SaleFaTabsState(
      tabs: [
        SaleFaTab(
          sessionKey: sessionKey,
          label: 'Sale FA #$saleFaNumber',
          saleFaNumber: saleFaNumber,
          batchId: initialBatchId,
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
    final saleFaNumber = _nextSaleFaNumber();
    final newTab = SaleFaTab(
      sessionKey: _sessionKeyForSaleFaNumber(saleFaNumber),
      label: 'Sale FA #$saleFaNumber',
      saleFaNumber: saleFaNumber,
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
    tabs[index] = SaleFaTab(
      sessionKey: tab.sessionKey,
      label: label,
      saleFaNumber: tab.saleFaNumber,
      batchId: tab.batchId,
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
