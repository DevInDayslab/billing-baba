import 'dart:async';

import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/utils/party_group_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partyGroupsProvider = NotifierProvider<PartyGroups, List<String>>(
  PartyGroups.new,
);

/// Set to `true` after party group names finish their first sync.
final partyGroupsStorageReadyProvider =
    NotifierProvider<PartyGroupsStorageReady, bool>(
      PartyGroupsStorageReady.new,
    );

class PartyGroupsStorageReady extends Notifier<bool> {
  @override
  bool build() => false;

  void markReady() => state = true;

  void reset() => state = false;
}

class PartyGroups extends Notifier<List<String>> {
  String? _activeBusinessId;
  var _synced = false;

  @override
  List<String> build() {
    ref.keepAlive();

    ref.listen(
      businessProfileProvider.select((profile) => profile.asData?.value.id),
      (previous, next) {
        if (next == null || next.isEmpty || next == previous) return;
        if (previous == null) {
          unawaited(_sync(next));
          return;
        }
        unawaited(_switchBusiness(next));
      },
    );

    ref.listen(partyListProvider, (previous, next) {
      if (_activeBusinessId == null) return;
      next.whenData((_) => unawaited(_mergeFromDiscoverySource()));
    });

    scheduleMicrotask(() {
      final businessId = ref.read(
        businessProfileProvider.select((profile) => profile.asData?.value.id),
      );
      if (businessId != null && businessId.isNotEmpty) {
        unawaited(_sync(businessId));
      }
    });

    return const [];
  }

  /// Re-runs discovery — used by the Groups page on open/refresh.
  Future<void> sync() async {
    final businessId = ref.read(
      businessProfileProvider.select((profile) => profile.asData?.value.id),
    );
    if (businessId == null || businessId.isEmpty) return;
    await _sync(businessId);
  }

  Future<void> _switchBusiness(String businessId) async {
    _activeBusinessId = businessId;
    _synced = false;
    state = const [];
    ref.read(partyGroupsStorageReadyProvider.notifier).reset();
    await _sync(businessId);
  }

  Future<void> _sync(String businessId) async {
    if (!ref.mounted) return;

    _activeBusinessId = businessId;

    try {
      final service = await ref.read(partyServiceProvider.future);
      if (!ref.mounted) return;

      final stored = await service.readPartyGroupNames();
      if (!ref.mounted) return;

      final parties = await service.loadPartiesForGroupDiscovery();
      if (!ref.mounted) return;

      _applyMergedNames([
        ...stored,
        ...state,
        ..._groupNamesFromParties(parties),
      ]);
    } on Object {
      // Keep in-memory state; groups can still be added manually.
    } finally {
      _synced = true;
      if (ref.mounted) {
        ref.read(partyGroupsStorageReadyProvider.notifier).markReady();
      }
    }
  }

  Future<void> _mergeFromDiscoverySource() async {
    if (!ref.mounted || _activeBusinessId == null) return;

    try {
      final service = await ref.read(partyServiceProvider.future);
      if (!ref.mounted) return;

      final parties = await service.loadPartiesForGroupDiscovery();
      if (!ref.mounted) return;

      _applyMergedNames([...state, ..._groupNamesFromParties(parties)]);
    } on Object {
      // Ignore merge errors; in-memory groups remain.
    }
  }

  Iterable<String> _groupNamesFromParties(List<PartyModel> parties) sync* {
    for (final party in parties) {
      final group = party.partyGroup.trim();
      if (group.isNotEmpty) yield group;
    }
  }

  void _applyMergedNames(Iterable<String> names) {
    final next = mergePartyGroupNames(names);
    if (partyGroupNamesEqual(next, state)) return;
    state = next;
    if (_synced) {
      unawaited(_persist());
    }
  }

  bool addGroup(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (partyGroupNameExists(state, trimmed)) return false;
    state = mergePartyGroupNames([...state, trimmed]);
    unawaited(_persist());
    return true;
  }

  bool renameGroup(String oldName, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == oldName) return false;
    if (partyGroupNameExists(
      [
        for (final group in state)
          if (group != oldName) group,
      ],
      trimmed,
    )) {
      return false;
    }

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

      final merged = mergePartyGroupNames([...stored, ...state]);
      if (!partyGroupNamesEqual(merged, state)) {
        state = merged;
      }
      await service.savePartyGroupNames(merged);
    } on Object {
      // Ignore persistence errors; groups remain in memory.
    }
  }
}
