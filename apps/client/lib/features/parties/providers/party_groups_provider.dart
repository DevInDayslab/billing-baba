import 'package:billing_baba/features/parties/providers/parties_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const defaultPartyGroups = [
  'Bags',
  'Retail',
  'Wholesale',
  'Distributors',
  'Etc',
];

final partyGroupsProvider =
    NotifierProvider<PartyGroups, List<String>>(PartyGroups.new);

class PartyGroups extends Notifier<List<String>> {
  @override
  List<String> build() => List.of(defaultPartyGroups);

  bool addGroup(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final exists = state.any(
      (group) => group.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return false;
    state = [...state, trimmed];
    return true;
  }

  bool renameGroup(String oldName, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == oldName) return false;
    final exists = state.any(
      (group) =>
          group.toLowerCase() == trimmed.toLowerCase() && group != oldName,
    );
    if (exists) return false;

    state = [
      for (final group in state) group == oldName ? trimmed : group,
    ];
    ref.read(partiesProvider.notifier).renamePartyGroup(oldName, trimmed);
    return true;
  }

  bool deleteGroup(String name) {
    if (!state.contains(name)) return false;
    state = state.where((group) => group != name).toList();
    ref.read(partiesProvider.notifier).clearPartyGroup(name);
    return true;
  }
}
