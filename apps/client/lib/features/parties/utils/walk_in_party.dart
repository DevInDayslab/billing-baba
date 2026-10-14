import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/utils/walk_in_party_ids.dart';
import 'package:billing_baba/features/pos/pos_constants.dart';

export 'walk_in_party_ids.dart';

/// Whether this party row is the system walk-in customer (not a real purchaser).
bool isWalkInParty(PartyModel party, {required String? businessId}) {
  if (party.id == PosConstants.walkInPartyId) return true;
  if (businessId != null && isWalkInPartyId(businessId, party.id)) {
    return true;
  }
  return isWalkInPartyName(party.name);
}

List<PartyModel> customerPartiesExcludingWalkIn(
  List<PartyModel> parties, {
  required String? businessId,
}) {
  return parties
      .where(
        (party) =>
            (party.partyType == 'customer' || party.partyType == 'both') &&
            !isWalkInParty(party, businessId: businessId),
      )
      .toList();
}
