import 'package:billing_baba/features/parties/models/party_group_summary.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/parties/providers/party_groups_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partyGroupSummariesProvider = Provider<List<PartyGroupSummary>>((ref) {
  final groups = ref.watch(partyGroupsProvider);
  final parties = ref.watch(partiesListProvider);
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

  final parties = ref.watch(partiesListProvider);
  final members = parties
      .where((party) => party.partyGroup.trim() == selectedGroup)
      .toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return members;
});

final selectedPartyGroupSummaryProvider = Provider<PartyGroupSummary?>((ref) {
  final selectedGroup = ref.watch(selectedPartyGroupProvider);
  if (selectedGroup == null) return null;

  final parties = ref.watch(partiesListProvider);
  return PartyGroupSummary.fromGroup(selectedGroup, parties);
});
