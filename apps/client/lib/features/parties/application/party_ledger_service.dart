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

@riverpod
class PartyTimeline extends _$PartyTimeline {
  var _refreshGeneration = 0;

  @override
  Future<PartyLedgerModel> build(String partyId) async {
    ref.onDispose(() => _refreshGeneration++);
    final service = await ref.watch(partyLedgerServiceProvider.future);
    return service.fetchPartyLedger(partyId);
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;

    final generation = ++_refreshGeneration;
    state = const AsyncLoading();

    final service = await ref.read(partyLedgerServiceProvider.future);
    if (!ref.mounted || generation != _refreshGeneration) return;

    final next = await AsyncValue.guard(
      () => service.fetchPartyLedger(partyId),
    );
    if (!ref.mounted || generation != _refreshGeneration) return;
    state = next;
  }
}

@riverpod
class PartyLedger extends _$PartyLedger {
  var _refreshGeneration = 0;

  @override
  Future<PartyLedgerModel> build(String partyId) async {
    ref.onDispose(() => _refreshGeneration++);
    final service = await ref.watch(partyLedgerServiceProvider.future);
    return service.fetchPartyLedger(partyId);
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;

    final generation = ++_refreshGeneration;
    state = const AsyncLoading();

    final service = await ref.read(partyLedgerServiceProvider.future);
    if (!ref.mounted || generation != _refreshGeneration) return;

    final next = await AsyncValue.guard(
      () => service.fetchPartyLedger(partyId),
    );
    if (!ref.mounted || generation != _refreshGeneration) return;
    state = next;
  }
}
