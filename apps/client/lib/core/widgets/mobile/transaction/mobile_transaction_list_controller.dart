import 'package:billing_baba/core/widgets/mobile/transaction/mobile_transaction_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search, filter, and sort UI state for a scoped transaction list.
class MobileTransactionListState {
  const MobileTransactionListState({
    this.searchQuery = '',
    this.filterKey,
    this.sort = const MobileTransactionSortState(),
  });

  final String searchQuery;
  final String? filterKey;
  final MobileTransactionSortState sort;

  bool get hasActiveFilter =>
      filterKey != null && filterKey != MobileFilterOption.allKey;

  MobileTransactionListState copyWith({
    String? searchQuery,
    String? filterKey,
    bool clearFilter = false,
    MobileTransactionSortState? sort,
  }) {
    return MobileTransactionListState(
      searchQuery: searchQuery ?? this.searchQuery,
      filterKey: clearFilter ? null : (filterKey ?? this.filterKey),
      sort: sort ?? this.sort,
    );
  }
}

/// Registry of list UI state keyed by page [scopeId].
final mobileTransactionListRegistryProvider =
    NotifierProvider<MobileTransactionListRegistry,
        Map<String, MobileTransactionListState>>(
  MobileTransactionListRegistry.new,
);

class MobileTransactionListRegistry
    extends Notifier<Map<String, MobileTransactionListState>> {
  @override
  Map<String, MobileTransactionListState> build() => {};

  MobileTransactionListState stateFor(String scope) {
    return state[scope] ?? const MobileTransactionListState();
  }

  void setSearch(String scope, String query) {
    state = {
      ...state,
      scope: stateFor(scope).copyWith(searchQuery: query),
    };
  }

  void setFilter(String scope, String? key) {
    if (key == null || key == MobileFilterOption.allKey) {
      state = {
        ...state,
        scope: stateFor(scope).copyWith(clearFilter: true),
      };
      return;
    }
    state = {
      ...state,
      scope: stateFor(scope).copyWith(filterKey: key),
    };
  }

  void setSort(String scope, MobileTransactionSortState sort) {
    state = {
      ...state,
      scope: stateFor(scope).copyWith(sort: sort),
    };
  }

  void reset(String scope) {
    final next = Map<String, MobileTransactionListState>.from(state)
      ..remove(scope);
    state = next;
  }
}

/// Watches list UI state for a single transaction page scope.
final mobileTransactionListStateProvider =
    Provider.family<MobileTransactionListState, String>((ref, scope) {
  final registry = ref.watch(mobileTransactionListRegistryProvider);
  return registry[scope] ?? const MobileTransactionListState();
});

List<MobileTransactionListItem> sortMobileTransactionItems(
  List<MobileTransactionListItem> items,
  MobileTransactionSortState sort,
) {
  if (!sort.isActive) return items;

  final ascending = sort.direction == MobileTransactionSortDirection.ascending;
  final sorted = List<MobileTransactionListItem>.from(items)
    ..sort((a, b) {
      final comparison = switch (sort.fieldKey) {
        'amount' => a.sortAmount.compareTo(b.sortAmount),
        'title' => (a.sortTitle ?? a.title).toLowerCase().compareTo(
          (b.sortTitle ?? b.title).toLowerCase(),
        ),
        _ => _compareDates(a.sortDate, b.sortDate),
      };
      return ascending ? comparison : -comparison;
    });
  return sorted;
}

int _compareDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

List<MobileTransactionListItem> filterMobileTransactionItems({
  required List<MobileTransactionListItem> items,
  required String query,
  String? filterKey,
  bool Function(MobileTransactionListItem item, String filterKey)? filterMatcher,
}) {
  var result = items;

  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isNotEmpty) {
    result = result.where((item) {
      final haystack = [
        item.title,
        item.subtitle,
        item.statusLabel,
        item.dateLabel,
        item.amountLabel,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList();
  }

  if (filterKey != null &&
      filterKey != MobileFilterOption.allKey &&
      filterMatcher != null) {
    result = result.where((item) => filterMatcher(item, filterKey)).toList();
  }

  return result;
}
