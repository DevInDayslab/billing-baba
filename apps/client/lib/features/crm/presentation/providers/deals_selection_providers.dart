import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/domain/services/deal_service_types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deals_selection_providers.g.dart';

enum DealsViewMode {
  kanban,
  list,
}

@Riverpod(keepAlive: true)
class DealsViewModeState extends _$DealsViewModeState {
  @override
  DealsViewMode build() => DealsViewMode.kanban;

  void setMode(DealsViewMode mode) => state = mode;
}

@Riverpod(keepAlive: true)
class SelectedDealIds extends _$SelectedDealIds {
  @override
  Set<String> build() => {};

  void toggle(String dealId) {
    final next = Set<String>.from(state);
    if (next.contains(dealId)) {
      next.remove(dealId);
    } else {
      next.add(dealId);
    }
    state = next;
  }

  void clear() => state = {};

  void remove(String dealId) {
    if (!state.contains(dealId)) return;
    state = Set<String>.from(state)..remove(dealId);
  }
}

@Riverpod(keepAlive: true)
class DealSearchQuery extends _$DealSearchQuery {
  @override
  String build() => '';

  set query(String value) => state = value;
}

@Riverpod(keepAlive: true)
class DealFilters extends _$DealFilters {
  @override
  DealFiltersState build() => const DealFiltersState();

  void setAccountName(String? accountName) {
    state = state.copyWith(accountName: () => accountName);
  }

  void setAssignedTo(String? assignedTo) {
    state = state.copyWith(assignedTo: () => assignedTo);
  }

  void setStage(DealStage? stage) {
    state = state.copyWith(stage: () => stage);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleSystemFilter(String filter) {
    final next = Set<String>.from(state.systemFilters);
    if (next.contains(filter)) {
      next.remove(filter);
    } else {
      next.add(filter);
    }
    state = state.copyWith(systemFilters: next);
  }

  void toggleFieldFilter(String filter) {
    final next = Set<String>.from(state.fieldFilters);
    if (next.contains(filter)) {
      next.remove(filter);
    } else {
      next.add(filter);
    }
    state = state.copyWith(fieldFilters: next);
  }

  DealQueryFilters toServiceFilters() {
    return DealQueryFilters(
      searchQuery: state.searchQuery,
      accountName: state.accountName,
      assignedTo: state.assignedTo,
      stage: state.stage,
    );
  }
}

class DealFiltersState {
  const DealFiltersState({
    this.searchQuery = '',
    this.accountName,
    this.assignedTo,
    this.stage,
    this.systemFilters = const {},
    this.fieldFilters = const {},
    this.filterPanelOpen = true,
  });

  final String searchQuery;
  final String? accountName;
  final String? assignedTo;
  final DealStage? stage;
  final Set<String> systemFilters;
  final Set<String> fieldFilters;
  final bool filterPanelOpen;

  String get ownerLabel => assignedTo ?? 'All Owners';
  String get accountLabel => accountName ?? 'All Accounts';

  DealFiltersState copyWith({
    String? searchQuery,
    String? Function()? accountName,
    String? Function()? assignedTo,
    DealStage? Function()? stage,
    Set<String>? systemFilters,
    Set<String>? fieldFilters,
    bool? filterPanelOpen,
  }) {
    return DealFiltersState(
      searchQuery: searchQuery ?? this.searchQuery,
      accountName: accountName != null ? accountName() : this.accountName,
      assignedTo: assignedTo != null ? assignedTo() : this.assignedTo,
      stage: stage != null ? stage() : this.stage,
      systemFilters: systemFilters ?? this.systemFilters,
      fieldFilters: fieldFilters ?? this.fieldFilters,
      filterPanelOpen: filterPanelOpen ?? this.filterPanelOpen,
    );
  }
}

@Riverpod(keepAlive: true)
class DealFilterPanelOpen extends _$DealFilterPanelOpen {
  @override
  bool build() => true;

  void toggle() => state = !state;

  set open(bool value) => state = value;
}
