import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/parties/data/party_ledger_remote_data_source.dart';
import 'package:billing_baba/features/parties/models/dto/party_ledger_dto.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'party_ledger_service.g.dart';

class PartyLedgerService {
  PartyLedgerService(this._remote);

  final PartyLedgerRemoteDataSource _remote;

  Future<PartyLedgerModel> fetchPartyLedger(
    String partyId, {
    PartyLedgerFilter filter = PartyLedgerFilter.all,
  }) async {
    final dto = await _remote.getPartyLedger(partyId, filter: filter);
    return PartyLedgerMapper.toModel(dto);
  }
}

@Riverpod(keepAlive: true)
Future<PartyLedgerService> partyLedgerService(Ref ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return PartyLedgerService(PartyLedgerRemoteDataSource(api.dio));
}

typedef PartyLedgerKey = ({String partyId, PartyLedgerFilter filter});

@riverpod
class PartyLedger extends _$PartyLedger {
  @override
  Future<PartyLedgerModel> build(PartyLedgerKey key) async {
    final service = await ref.watch(partyLedgerServiceProvider.future);
    return service.fetchPartyLedger(key.partyId, filter: key.filter);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(partyLedgerServiceProvider.future);
      return service.fetchPartyLedger(key.partyId, filter: key.filter);
    });
  }
}
