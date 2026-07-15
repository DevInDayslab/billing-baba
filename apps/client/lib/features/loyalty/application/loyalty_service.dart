import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/loyalty/data/loyalty_repository.dart';
import 'package:billing_baba/features/loyalty/models/loyalty_dto.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loyalty_service.g.dart';

abstract final class LoyaltyRules {
  static bool isEligibleParty(PartyModel? party) {
    if (party == null) return false;
    return party.partyType == 'customer' || party.partyType == 'both';
  }

  /// Hide loyalty on party details when outstanding is payable (red amount in list).
  static bool shouldShowPartyLoyalty(
    PartyModel party, {
    double? outstanding,
  }) {
    if (!isEligibleParty(party)) return false;
    final balance = outstanding ?? party.balance;
    return balance >= 0;
  }
}

String _formatLoyaltyPointsValue(double value) {
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(4);
}

void applySaleLoyaltyToCache(
  Ref ref, {
  required String partyId,
  required SaleLoyaltyResultDto loyalty,
}) {
  ref
      .read(partyLoyaltyBalanceCacheProvider.notifier)
      .applySaleResult(partyId, loyalty);
}

@Riverpod(keepAlive: true)
class PartyLoyaltyBalanceCache extends _$PartyLoyaltyBalanceCache {
  @override
  Map<String, PartyLoyaltyBalanceDto> build() => {};

  void upsert(String partyId, PartyLoyaltyBalanceDto balance) {
    state = {...state, partyId: balance};
  }

  void applySaleResult(String partyId, SaleLoyaltyResultDto loyalty) {
    final existing = state[partyId];
    final earnedThisSale = loyalty.earnedPointsInt;
    final earnedTotal = existing != null
        ? existing.earnedPointsValue + earnedThisSale
        : earnedThisSale.toDouble();

    upsert(
      partyId,
      PartyLoyaltyBalanceDto(
        partyId: partyId,
        pointsEarned: _formatLoyaltyPointsValue(earnedTotal),
        pointsAvailable: loyalty.pointsAvailable,
      ),
    );
  }
}

@Riverpod(keepAlive: true)
Future<LoyaltyService> loyaltyService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return LoyaltyService(LoyaltyRepository(api.dio));
}

class LoyaltyService {
  LoyaltyService(this._repository);

  final LoyaltyRepository _repository;

  Future<PartyLoyaltyBalanceDto> getPartyBalance(String partyId) {
    return _repository.getPartyBalance(partyId);
  }
}

@riverpod
Future<PartyLoyaltyBalanceDto> partyLoyaltyBalance(Ref ref, String partyId) async {
  final service = await ref.watch(loyaltyServiceProvider.future);
  try {
    final balance = await service.getPartyBalance(partyId);
    ref.read(partyLoyaltyBalanceCacheProvider.notifier).upsert(partyId, balance);
    return balance;
  } on Object {
    final cached = ref.watch(partyLoyaltyBalanceCacheProvider)[partyId];
    if (cached != null) return cached;
    return PartyLoyaltyBalanceDto(
      partyId: partyId,
      pointsEarned: '0',
      pointsAvailable: '0',
    );
  }
}
