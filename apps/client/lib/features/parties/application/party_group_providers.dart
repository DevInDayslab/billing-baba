import 'package:billing_baba/features/parties/models/party_group_summary.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_groups_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<PartyModel> _allPartiesOrEmpty(AsyncValue<List<PartyModel>> async) {
  return async.maybeWhen(
    data: (parties) => parties,
    orElse: () => const <PartyModel>[],
  );
}

/// True while party group names are syncing for the first time.
final partyGroupsPageLoadingProvider = Provider<bool>((ref) {
  return !ref.watch(partyGroupsStorageReadyProvider);
});

/// True while party members for the selected group are still loading.
final partyGroupMembersLoadingProvider = Provider<bool>((ref) {
  final partiesAsync = ref.watch(allPartiesListProvider);
  return partiesAsync.isLoading;
});

final partyGroupSummariesProvider = Provider<List<PartyGroupSummary>>((ref) {
  final groups = ref.watch(partyGroupsProvider);
  final parties = _allPartiesOrEmpty(ref.watch(allPartiesListProvider));
  final search = ref.watch(partyGroupSearchQueryProvider).trim().toLowerCase();

  final summaries = groups
      .map((group) => PartyGroupSummary.fromGroup(group, parties))
      .toList();

  if (search.isEmpty) return summaries;

  return summaries
      .where((summary) => summary.name.toLowerCase().contains(search))
      .toList();
});

final partiesInSelectedGroupProvider = Provider<List<PartyModel>>((ref) {
  final selectedGroup = ref.watch(selectedPartyGroupProvider);
  if (selectedGroup == null) return const [];

  final parties = _allPartiesOrEmpty(ref.watch(allPartiesListProvider));
  final members = parties
      .where((party) => party.partyGroup.trim() == selectedGroup)
      .toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return members;
});

final selectedPartyGroupSummaryProvider = Provider<PartyGroupSummary?>((ref) {
  final selectedGroup = ref.watch(selectedPartyGroupProvider);
  if (selectedGroup == null) return null;

  final parties = _allPartiesOrEmpty(ref.watch(allPartiesListProvider));
  return PartyGroupSummary.fromGroup(selectedGroup, parties);
});
