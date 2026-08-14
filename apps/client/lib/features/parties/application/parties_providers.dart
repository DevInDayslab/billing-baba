import 'package:billing_baba/features/parties/application/parties_selection_providers.dart';
import 'package:billing_baba/features/parties/application/party_ledger_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/utils/party_projected_balance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:billing_baba/features/parties/utils/party_projected_balance.dart';
export 'parties_selection_providers.dart';

/// Full party list for searchable pickers — ignores Parties page filters/search.
/// keepAlive so the fetched list survives navigation and the party picker
/// is instant on every open after the first load.
final partyPickerListProvider = FutureProvider<List<PartyModel>>((ref) async {
  ref.keepAlive();

  // Stay in sync with the parties page list (including profile image patches).
  final cachedParties = ref.watch(partyListProvider).asData?.value;
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
  final async = ref.watch(partyListProvider);
  return async.asData?.value ?? const <PartyModel>[];
});

/// Projected outstanding balances keyed by party id (local Drift ledger).
final partyOutstandingIndexProvider = FutureProvider<Map<String, double>>((
  ref,
) async {
  ref.watch(partyListProvider);
  final service = await ref.watch(partyLedgerServiceProvider.future);
  final businessId = await ref.watch(partyLedgerBusinessIdProvider.future);
  return service.fetchOutstandingIndex(businessId: businessId);
});

/// Unfiltered parties for group membership and group-name discovery.
/// Rebuilds when [partyListProvider] changes so CRUD stays in sync.
final allPartiesListProvider = FutureProvider<List<PartyModel>>((ref) async {
  ref
    ..keepAlive()
    ..watch(partyListProvider);
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
  final outstandingIndex = ref.watch(partyOutstandingIndexProvider).value;

  var totalReceivable = 0.0;
  var receivablePartyCount = 0;
  var totalPayable = 0.0;
  var payablePartyCount = 0;

  for (final party in parties) {
    final balance = projectedPartyBalance(party, outstandingIndex);
    final projected = party.copyWith(balance: balance);
    if (projected.hasReceivable) {
      totalReceivable += balance;
      receivablePartyCount++;
    } else if (projected.hasPayable) {
      totalPayable += balance.abs();
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
