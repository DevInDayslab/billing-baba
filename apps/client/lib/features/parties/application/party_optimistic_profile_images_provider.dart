import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory party profile previews for instant list/detail updates while upload runs.
class PartyOptimisticProfileImages
    extends Notifier<Map<String, Uint8List>> {
  @override
  Map<String, Uint8List> build() => const {};

  void setBytes(String partyId, Uint8List bytes) {
    state = {...state, partyId: bytes};
  }

  void clear(String partyId) {
    if (!state.containsKey(partyId)) return;
    final next = Map<String, Uint8List>.from(state)..remove(partyId);
    state = next;
  }
}

final partyOptimisticProfileImagesProvider =
    NotifierProvider<PartyOptimisticProfileImages, Map<String, Uint8List>>(
  PartyOptimisticProfileImages.new,
);
