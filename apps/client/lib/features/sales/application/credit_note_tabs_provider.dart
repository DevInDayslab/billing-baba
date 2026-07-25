import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credit_note_tabs_provider.g.dart';

String creditNoteTabLabelForForm({
  required int creditNoteNumber,
  String? partyName,
}) {
  final party = partyName?.trim();
  if (party != null && party.isNotEmpty) {
    return party;
  }
  return 'Credit Note #$creditNoteNumber';
}

class CreditNoteTab {
  const CreditNoteTab({
    required this.sessionKey,
    required this.label,
    required this.creditNoteNumber,
    this.documentId,
  });

  final String sessionKey;
  final String label;
  final int creditNoteNumber;
  final String? documentId;
}

class CreditNoteTabsState {
  const CreditNoteTabsState({
    required this.tabs,
    required this.activeIndex,
  });

  final List<CreditNoteTab> tabs;
  final int activeIndex;

  CreditNoteTab get activeTab => tabs[activeIndex];

  CreditNoteTabsState copyWith({
    List<CreditNoteTab>? tabs,
    int? activeIndex,
  }) {
    return CreditNoteTabsState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
    );
  }
}

int _tabCounter = 0;

int _nextCreditNoteNumber() {
  _tabCounter += 1;
  return _tabCounter;
}

String _sessionKeyForCreditNoteNumber(int creditNoteNumber) =>
    'credit_note_tab_$creditNoteNumber';

@riverpod
class CreditNoteTabs extends _$CreditNoteTabs {
  static const maxTabs = 10;

  bool get canAddTab => state.tabs.length < maxTabs;

  @override
  CreditNoteTabsState build({String? initialDocumentId}) {
    final creditNoteNumber = _nextCreditNoteNumber();
    final sessionKey =
        initialDocumentId ?? _sessionKeyForCreditNoteNumber(creditNoteNumber);
    return CreditNoteTabsState(
      tabs: [
        CreditNoteTab(
          sessionKey: sessionKey,
          label: 'Credit Note #$creditNoteNumber',
          creditNoteNumber: creditNoteNumber,
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
    final creditNoteNumber = _nextCreditNoteNumber();
    final newTab = CreditNoteTab(
      sessionKey: _sessionKeyForCreditNoteNumber(creditNoteNumber),
      label: 'Credit Note #$creditNoteNumber',
      creditNoteNumber: creditNoteNumber,
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
    tabs[index] = CreditNoteTab(
      sessionKey: tab.sessionKey,
      label: label,
      creditNoteNumber: tab.creditNoteNumber,
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
