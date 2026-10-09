import 'package:billing_baba/features/parties/models/party_model.dart';

/// Ledger-projected outstanding for a party (local Drift index when available).
double projectedPartyBalance(
  PartyModel party,
  Map<String, double>? outstandingIndex,
) {
  final projected = outstandingIndex?[party.id];
  if (projected != null) return projected;
  final cachedBalance = party.balance;
  if (cachedBalance != 0) return cachedBalance;
  return party.openingBalance;
}
