import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileHomeState {
  const MobileHomeState({
    this.activeView = MobileHomeView.transactionDetails,
    this.searchQuery = '',
    this.transactionTypeFilters = const {},
  });

  final MobileHomeView activeView;
  final String searchQuery;
  final Set<MobileHomeTransactionFilterType> transactionTypeFilters;

  MobileHomeState copyWith({
    MobileHomeView? activeView,
    String? searchQuery,
    Set<MobileHomeTransactionFilterType>? transactionTypeFilters,
  }) {
    return MobileHomeState(
      activeView: activeView ?? this.activeView,
      searchQuery: searchQuery ?? this.searchQuery,
      transactionTypeFilters:
          transactionTypeFilters ?? this.transactionTypeFilters,
    );
  }
}

final mobileHomeControllerProvider =
    NotifierProvider<MobileHomeController, MobileHomeState>(
      MobileHomeController.new,
    );

class MobileHomeController extends Notifier<MobileHomeState> {
  @override
  MobileHomeState build() => const MobileHomeState();

  void setView(MobileHomeView view) {
    state = state.copyWith(activeView: view);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTransactionTypeFilters(
    Set<MobileHomeTransactionFilterType> filters,
  ) {
    state = state.copyWith(transactionTypeFilters: filters);
  }
}

List<MobileHomeTransactionItem> filterHomeTransactions(
  List<MobileHomeTransactionItem> items,
  String query, {
  Set<MobileHomeTransactionFilterType> typeFilters = const {},
}) {
  var result = items;

  if (typeFilters.isNotEmpty) {
    result = result
        .where((item) => typeFilters.contains(item.filterType))
        .toList();
  }

  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return result;

  return result.where((item) {
    final haystack = [
      item.partyName,
      item.documentNumber,
      item.statusLabel,
      item.dateLabel,
      item.totalLabel,
    ].join(' ').toLowerCase();
    return haystack.contains(normalized);
  }).toList();
}
