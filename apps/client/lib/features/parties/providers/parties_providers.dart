import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_selection_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'parties_selection_providers.dart';

/// Full party list for searchable pickers — ignores Parties page filters/search.
/// keepAlive so the fetched list survives navigation and the party picker
/// is instant on every open after the first load.
final partyPickerListProvider = FutureProvider<List<PartyModel>>((ref) async {
  ref.keepAlive();

  // Reuse partyListProvider data when already loaded (also keepAlive),
  // avoiding a duplicate API call.
  final cachedParties = ref.read(partyListProvider).asData?.value;
  if (cachedParties != null && cachedParties.isNotEmpty) {
    return cachedParties;
  }

  // First load or cache miss — fetch fresh from API.
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

/// Unfiltered parties for group membership and group-name discovery.
/// Rebuilds when [partyListProvider] changes so CRUD stays in sync.
final allPartiesListProvider = FutureProvider<List<PartyModel>>((ref) async {
  ref.keepAlive();
  ref.watch(partyListProvider);
  final service = await ref.watch(partyServiceProvider.future);
  return service.loadPartiesForGroupDiscovery();
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
