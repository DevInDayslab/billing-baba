import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileHomeState {
  const MobileHomeState({
    this.activeView = MobileHomeView.transactionDetails,
    this.searchQuery = '',
  });

  final MobileHomeView activeView;
  final String searchQuery;

  MobileHomeState copyWith({
    MobileHomeView? activeView,
    String? searchQuery,
  }) {
    return MobileHomeState(
      activeView: activeView ?? this.activeView,
      searchQuery: searchQuery ?? this.searchQuery,
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
}

List<MobileHomeTransactionItem> filterHomeTransactions(
  List<MobileHomeTransactionItem> items,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return items;

  return items.where((item) {
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
