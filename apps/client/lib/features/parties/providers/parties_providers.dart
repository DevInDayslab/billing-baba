import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_selection_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'parties_selection_providers.dart';

/// Full party list for searchable pickers — ignores Parties page filters/search.
final partyPickerListProvider = FutureProvider<List<PartyModel>>((ref) async {
  final service = await ref.watch(partyServiceProvider.future);
  return service.fetchParties();
});

final partyNamesProvider = Provider<List<String>>((ref) {
  final parties = ref.watch(partyListProvider);
  return parties.maybeWhen(
    data: (items) => items.map((party) => party.name).toList(),
    orElse: () => [],
  );
});

final partiesListProvider = Provider<List<PartyModel>>((ref) {
  return ref
      .watch(partyListProvider)
      .maybeWhen(
        data: (items) => items,
        orElse: () => const <PartyModel>[],
      );
});

/// Parties list with the Parties page filters applied — instant, client-side.
final filteredPartiesListProvider = Provider<List<PartyModel>>((ref) {
  final filters = ref.watch(partyListFilterProvider);
  final typeFilter = ref.watch(partyTypeFilterProvider);
  final parties = ref.watch(partiesListProvider);

  return parties
      .where((party) {
        if (!typeFilter.matches(party.partyType)) return false;
        return filters.matches(party);
      })
      .toList()
    ..sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
});

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
  final parties = ref
      .watch(partyListProvider)
      .maybeWhen(
        data: (items) => items,
        orElse: () => const <PartyModel>[],
      );

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

  final detail = ref.watch(partyDetailProvider(selectedId));
  return detail.maybeWhen(
    data: (party) => party,
    orElse: () {
      final parties = ref
          .watch(partyListProvider)
          .maybeWhen(
            data: (items) => items,
            orElse: () => const <PartyModel>[],
          );
      return parties.where((party) => party.id == selectedId).firstOrNull;
    },
  );
});
