import 'package:billing_baba/features/parties/models/add_party_result.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/providers/party_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partiesProvider =
    NotifierProvider<Parties, List<PartyModel>>(Parties.new);

class Parties extends Notifier<List<PartyModel>> {
  @override
  List<PartyModel> build() => List.of(PartyCatalog.parties);

  String? addParty(PartyModel party) {
    final trimmedName = party.name.trim();
    if (trimmedName.isEmpty) return null;
    if (state.any(
      (existing) =>
          existing.name.toLowerCase() == trimmedName.toLowerCase(),
    )) {
      return null;
    }
    state = [...state, party];
    return party.id;
  }

  String? addPartyFromResult(AddPartyResult result) {
    final id = 'party-${DateTime.now().millisecondsSinceEpoch}';
    return addParty(PartyModel.fromAddPartyResult(result, id: id));
  }

  void updateParty(PartyModel party) {
    final index = state.indexWhere((existing) => existing.id == party.id);
    if (index == -1) return;

    final next = List<PartyModel>.from(state);
    next[index] = party;
    state = next;
  }

  bool updatePartyFromResult(String partyId, AddPartyResult result) {
    final trimmedName = result.partyName.trim();
    if (trimmedName.isEmpty) return false;

    final index = state.indexWhere((party) => party.id == partyId);
    if (index == -1) return false;

    final hasDuplicateName = state.any(
      (existing) =>
          existing.id != partyId &&
          existing.name.toLowerCase() == trimmedName.toLowerCase(),
    );
    if (hasDuplicateName) return false;

    final existing = state[index];
    final updated = PartyModel.fromAddPartyResult(result, id: partyId).copyWith(
      isActive: existing.isActive,
    );

    final next = List<PartyModel>.from(state);
    next[index] = updated;
    state = next;
    return true;
  }

  void renamePartyGroup(String oldName, String newName) {
    state = [
      for (final party in state)
        party.partyGroup == oldName
            ? party.copyWith(partyGroup: newName)
            : party,
    ];
  }

  void clearPartyGroup(String groupName) {
    state = [
      for (final party in state)
        party.partyGroup == groupName
            ? party.copyWith(partyGroup: '')
            : party,
    ];
  }

  void addPartyFromFields({
    required String name,
    String phone = '',
  }) {
    addParty(
      PartyModel(
        id: 'party-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        phone: phone.trim().isEmpty ? '+91 00000 00000' : phone.trim(),
      ),
    );
  }
}
