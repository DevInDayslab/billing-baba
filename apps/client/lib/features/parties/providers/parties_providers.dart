import 'package:billing_baba/features/parties/models/party_list_filter.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_provider.dart';
import 'package:billing_baba/features/parties/providers/party_transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final partyNamesProvider = Provider<List<String>>((ref) {
  return ref.watch(partiesProvider).map((party) => party.name).toList();
});

final partiesListProvider = Provider<List<PartyModel>>((ref) {
  final query = ref.watch(partySearchQueryProvider).toLowerCase();
  final filter = ref.watch(partyListFilterProvider);

  final filtered = ref.watch(partiesProvider).where((party) {
    final matchesSearch =
        query.isEmpty || party.name.toLowerCase().contains(query);
    if (!matchesSearch) return false;

    return switch (filter) {
      PartyListFilter.all => true,
      PartyListFilter.toReceive => party.hasReceivable,
      PartyListFilter.toPay => party.hasPayable,
      PartyListFilter.active => party.isActive,
      PartyListFilter.inactive => !party.isActive,
    };
  }).toList();

  filtered.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
  return filtered;
});

final selectedPartyIdProvider =
    NotifierProvider<SelectedPartyId, String?>(SelectedPartyId.new);

final partySearchQueryProvider =
    NotifierProvider<PartySearchQuery, String>(PartySearchQuery.new);

final partyListFilterProvider =
    NotifierProvider<PartyListFilterNotifier, PartyListFilter>(
      PartyListFilterNotifier.new,
    );

final partyTransactionsProvider = partyTransactionsForPartyProvider;

class PartyBalanceSummary {
  const PartyBalanceSummary({
    required this.totalReceivable,
    required this.receivablePartyCount,
    required this.totalPayable,
    required this.payablePartyCount,
  });

  final double totalReceivable;
  final int receivablePartyCount;
  final double totalPayable;
  final int payablePartyCount;
}

final partyBalanceSummaryProvider = Provider<PartyBalanceSummary>((ref) {
  final parties = ref.watch(partiesProvider);

  var totalReceivable = 0.0;
  var receivablePartyCount = 0;
  var totalPayable = 0.0;
  var payablePartyCount = 0;

  for (final party in parties) {
    if (party.hasReceivable) {
      totalReceivable += party.balance;
      receivablePartyCount++;
    } else if (party.hasPayable) {
      totalPayable += party.balance.abs();
      payablePartyCount++;
    }
  }

  return PartyBalanceSummary(
    totalReceivable: totalReceivable,
    receivablePartyCount: receivablePartyCount,
    totalPayable: totalPayable,
    payablePartyCount: payablePartyCount,
  );
});

final selectedPartyProvider = Provider<PartyModel?>((ref) {
  final selectedId = ref.watch(selectedPartyIdProvider);
  if (selectedId == null) return null;
  return ref
      .watch(partiesProvider)
      .where((party) => party.id == selectedId)
      .firstOrNull;
});

class SelectedPartyId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

class PartySearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class PartyListFilterNotifier extends Notifier<PartyListFilter> {
  @override
  PartyListFilter build() => PartyListFilter.all;

  void select(PartyListFilter filter) => state = filter;
}
