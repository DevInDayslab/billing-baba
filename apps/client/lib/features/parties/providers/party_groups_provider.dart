import 'dart:async';

import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partyGroupsProvider = NotifierProvider<PartyGroups, List<String>>(
  PartyGroups.new,
);

class PartyGroups extends Notifier<List<String>> {
  var _storageLoaded = false;

  @override
  List<String> build() {
    ref.listen(partiesListProvider, (previous, next) {
      if (_storageLoaded) {
        scheduleMicrotask(() => _mergeFromParties(next));
      }
    });

    scheduleMicrotask(_loadFromStorage);
    return const [];
  }

  Future<void> _loadFromStorage() async {
    if (!ref.mounted) return;

    try {
      final service = await ref.read(partyServiceProvider.future);
      final stored = await service.readPartyGroupNames();
      if (!ref.mounted) return;

      if (stored.isNotEmpty) {
        state = _sortedUnique([...stored, ...state]);
      }
      _mergeFromParties(ref.read(partiesListProvider));
    } on Object {
      // Keep empty list; groups can still be added manually.
    } finally {
      _storageLoaded = true;
    }
  }

  void _mergeFromParties(List<PartyModel> parties) {
    if (!ref.mounted) return;

    final merged = <String>{...state};
    for (final party in parties) {
      final group = party.partyGroup.trim();
      if (group.isNotEmpty) merged.add(group);
    }
    final next = _sortedUnique(merged);
    if (!_listsEqual(next, state)) {
      state = next;
      if (_storageLoaded) {
        unawaited(_persist());
      }
    }
  }

  bool addGroup(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final exists = state.any(
      (group) => group.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return false;
    state = _sortedUnique([...state, trimmed]);
    unawaited(_persist());
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
    ref.read(partyListProvider.notifier).renamePartyGroup(oldName, trimmed);
    unawaited(_persist());
    return true;
  }

  bool deleteGroup(String name) {
    if (!state.contains(name)) return false;
    state = state.where((group) => group != name).toList();
    ref.read(partyListProvider.notifier).clearPartyGroup(name);
    unawaited(_persist());
    return true;
  }

  Future<void> _persist() async {
    if (!ref.mounted) return;
    try {
      final service = await ref.read(partyServiceProvider.future);
      final stored = await service.readPartyGroupNames();
      if (!ref.mounted) return;

      final merged = _sortedUnique([...stored, ...state]);
      if (!_listsEqual(merged, state)) {
        state = merged;
      }
      await service.savePartyGroupNames(merged);
    } on Object {
      // Ignore persistence errors; groups remain in memory.
    }
  }

  List<String> _sortedUnique(Iterable<String> names) {
    final unique = <String>{};
    for (final name in names) {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty) unique.add(trimmed);
    }
    return unique.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
