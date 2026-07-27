import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/category_sync.dart';
import 'package:billing_baba/features/inventory/data/godown_sync.dart';
import 'package:billing_baba/features/inventory/data/item_sync.dart';
import 'package:billing_baba/features/inventory/data/unit_sync.dart';
import 'package:billing_baba/features/parties/data/party_sync.dart';
import 'package:billing_baba/features/settings/data/business_settings_sync.dart';
import 'package:billing_baba/features/settings/data/tax_rate_local_source.dart';
import 'package:billing_baba/features/settings/data/tax_rate_master_repository.dart';
import 'package:billing_baba/features/settings/data/tax_rate_sync.dart';
import 'package:billing_baba/features/settings/models/tax_rate_models.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSyncApi extends SyncApi {
  _FakeSyncApi() : super(Dio());
  Map<String, dynamic> Function(Map<String, dynamic> body)? pushHandler;
  Map<String, dynamic> pullPayload = const {
    'changes': <Map<String, dynamic>>[],
    'next_cursor': 'cursor-after-pull',
    'has_more': false,
  };
  @override
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String platform,
    required String appVersion,
    required String deviceName,
  }) async => {'device_id': deviceId};
  @override
  Future<Map<String, dynamic>> status({
    required String deviceId,
    required String appVersion,
  }) async => const {'schema_version': 1, 'protocol_version': 1};
  @override
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  }) async {
    if (pushHandler != null) return pushHandler!(body);
    final mutations = (body['mutations'] as List?) ?? const [];
    return {
      'accepted': [
        for (final m in mutations)
          if (m is Map)
            {
              'mutation_id': m['mutation_id'],
              'sync_version': 3,
              'server_updated_at': DateTime.utc(2026, 6).toIso8601String(),
            },
      ],
      'replayed': <Map<String, dynamic>>[],
      'conflicts': <Map<String, dynamic>>[],
      'errors': <Map<String, dynamic>>[],
    };
  }
  @override
  Future<Map<String, dynamic>> pull({
    required String deviceId,
    required String appVersion,
    required String cursor,
    int? limit,
    String? entityTypes,
  }) async => pullPayload;
}

void main() {
  late StorageService storage;
  late AppDatabase db;
  late SyncQueue queue;
  late TaxRateLocalSource rates;
  late TaxRateMasterRepository repo;
  late SyncMetadataStore metadata;
  late _FakeSyncApi api;
  late SyncCoordinator coordinator;

  setUp(() async {
    SharedPreferences.setMockInitialValues({StorageKeys.lastOpenedBusinessId: 'biz-1'});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(preferences: prefs);
    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(db);
    rates = TaxRateLocalSource(db);
    metadata = SyncMetadataStore(storage);
    api = _FakeSyncApi();
    repo = TaxRateMasterRepository(
      local: rates,
      syncQueue: queue,
      businessIdReader: () => storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
      deviceIdReader: () => '22222222-2222-2222-2222-222222222222',
    );
    final identity = SyncDeviceIdentity(
      storage,
      packageInfoLoader: () async => PackageInfo(
        appName: 'Billing Baba', packageName: 'billing_baba', version: '1.0.0', buildNumber: '1',
      ),
      platformName: () => 'test',
    );
    coordinator = SyncCoordinator(
      api: api, queue: queue, identity: identity, metadata: metadata, storage: storage,
      categorySync: CategorySync(db), partySync: PartySync(db), itemSync: ItemSync(db),
      unitSync: UnitSync(db), taxRateSync: TaxRateSync(db), godownSync: GodownSync(db),
      businessSettingsSync: BusinessSettingsSync(db),
    );
  });

  tearDown(() async { coordinator.dispose(); await db.close(); });

  Future<void> syncNow() async {
    var state = const SyncState(connectivity: SyncConnectivityStatus.online);
    await coordinator.orchestrate(currentState: state, emit: (u) => state = u(state));
  }

  test('offline CRUD + push ACK + conflict + pull soft-delete', () async {
    final created = await repo.create(const CreateTaxRateRequest(name: 'GST 18', rate: '18'));
    expect(created.name, 'GST 18');
    expect((await queue.listPending()).single.entityType, 'tax_rates');
    await repo.update(created.id, const UpdateTaxRateRequest(name: 'GST 18%'));
    await repo.softDelete(created.id);
    expect((await rates.getById(created.id))!.isDeleted, isTrue);
    expect(await queue.pendingCount(), 3);

    // fresh create for push/conflict/pull
    final alive = await repo.create(const CreateTaxRateRequest(name: 'GST 5', rate: '5'));
    await syncNow();
    expect((await rates.getById(alive.id))!.syncVersion, 3);

    final conflicted = await repo.create(const CreateTaxRateRequest(name: 'Local', rate: '12'));
    api.pushHandler = (body) {
      final mid = (body['mutations'] as List).first['mutation_id'];
      return {
        'accepted': <Map<String, dynamic>>[],
        'replayed': <Map<String, dynamic>>[],
        'conflicts': [{'mutation_id': mid, 'code': 'VERSION_CONFLICT', 'server_payload': {'name': 'Srv'}, 'server_sync_version': 9}],
        'errors': <Map<String, dynamic>>[],
      };
    };
    await syncNow();
    expect((await rates.getById(conflicted.id))!.name, 'Local');

    await metadata.setPullCursor('c');
    await metadata.setBootstrappedAt(DateTime.utc(2026));
    await metadata.setLastServerSchemaVersion(1);
    const id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    api.pushHandler = null;
    api.pullPayload = {
      'changes': [{
        'entity_type': 'tax_rates',
        'entity_id': id,
        'sync_version': 2,
        'updated_at': DateTime.utc(2026, 8).toIso8601String(),
        'is_deleted': false,
        'payload': {'name': 'Pulled', 'rate': '28', 'is_default': true},
      }],
      'next_cursor': 'cursor-after-pull',
      'has_more': false,
    };
    await syncNow();
    expect((await rates.getById(id))!.name, 'Pulled');
    expect((await rates.getById(id))!.isDefault, isTrue);
  });
}
