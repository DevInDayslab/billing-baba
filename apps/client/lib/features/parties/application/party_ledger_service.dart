import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/parties/application/party_projection_service.dart';
import 'package:billing_baba/features/parties/data/party_ledger_local_data_source.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_projection_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'party_ledger_service.g.dart';

class PartyLedgerService {
  PartyLedgerService(this._projection);

  final PartyProjectionService _projection;

  Future<PartyLedgerModel> fetchPartyLedger({
    required String businessId,
    required String partyId,
    PartyLedgerFilter filter = PartyLedgerFilter.all,
  }) {
    return _projection.buildLedger(
      businessId: businessId,
      partyId: partyId,
      filter: filter,
    );
  }

  Future<PartyProjection> fetchProjection({
    required String businessId,
    required String partyId,
    PartyLedgerFilter filter = PartyLedgerFilter.all,
  }) {
    return _projection.buildProjection(
      businessId: businessId,
      partyId: partyId,
      filter: filter,
    );
  }

  void invalidateCache({String? partyId}) {
    _projection.invalidateCache(partyId: partyId);
  }
}

@Riverpod(keepAlive: true)
Future<PartyLedgerService> partyLedgerService(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final projection = PartyProjectionService(PartyLedgerLocalDataSource(db));
  ref.onDispose(projection.invalidateCache);
  return PartyLedgerService(projection);
}

@Riverpod(keepAlive: true)
Future<String> partyLedgerBusinessId(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  final businessId = storage.read(StorageKeys.lastOpenedBusinessId)?.trim();
  if (businessId == null || businessId.isEmpty) {
    throw StateError('Business must be selected');
  }
  return businessId;
}

@Riverpod(keepAlive: true)
class PartyProfileProjection extends _$PartyProfileProjection {
  @override
  Future<PartyProjection> build(String partyId) async {
    final service = await ref.watch(partyLedgerServiceProvider.future);
    final businessId = await ref.watch(partyLedgerBusinessIdProvider.future);
    return service.fetchProjection(
      businessId: businessId,
      partyId: partyId,
    );
  }

  Future<void> refresh() async {
    final service = await ref.read(partyLedgerServiceProvider.future);
    service.invalidateCache(partyId: partyId);
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
class PartyTimeline extends _$PartyTimeline {
  var _refreshGeneration = 0;

  @override
  Future<PartyLedgerModel> build(String partyId) async {
    ref.onDispose(() => _refreshGeneration++);
    final service = await ref.watch(partyLedgerServiceProvider.future);
    final businessId = await ref.watch(partyLedgerBusinessIdProvider.future);
    return service.fetchPartyLedger(
      businessId: businessId,
      partyId: partyId,
    );
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;

    final generation = ++_refreshGeneration;
    state = const AsyncLoading();

    final service = await ref.read(partyLedgerServiceProvider.future);
    service.invalidateCache(partyId: partyId);
    if (!ref.mounted || generation != _refreshGeneration) return;

    final businessId = await ref.read(partyLedgerBusinessIdProvider.future);
    if (!ref.mounted || generation != _refreshGeneration) return;

    final next = await AsyncValue.guard(
      () => service.fetchPartyLedger(
        businessId: businessId,
        partyId: partyId,
      ),
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
    final businessId = await ref.watch(partyLedgerBusinessIdProvider.future);
    return service.fetchPartyLedger(
      businessId: businessId,
      partyId: partyId,
    );
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;

    final generation = ++_refreshGeneration;
    state = const AsyncLoading();

    final service = await ref.read(partyLedgerServiceProvider.future);
    service.invalidateCache(partyId: partyId);
    if (!ref.mounted || generation != _refreshGeneration) return;

    final businessId = await ref.read(partyLedgerBusinessIdProvider.future);
    if (!ref.mounted || generation != _refreshGeneration) return;

    final next = await AsyncValue.guard(
      () => service.fetchPartyLedger(
        businessId: businessId,
        partyId: partyId,
      ),
    );
    if (!ref.mounted || generation != _refreshGeneration) return;
    state = next;
  }
}
