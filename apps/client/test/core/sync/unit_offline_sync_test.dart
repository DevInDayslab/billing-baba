import 'dart:io';

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
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_sync.dart';
import 'package:billing_baba/features/inventory/data/unit_local_source.dart';
import 'package:billing_baba/features/inventory/data/unit_master_repository.dart';
import 'package:billing_baba/features/inventory/data/unit_sync.dart';
import 'package:billing_baba/features/inventory/models/requests/unit_requests.dart';
import 'package:billing_baba/features/parties/data/party_sync.dart';
import 'package:billing_baba/features/settings/data/business_settings_sync.dart';
import 'package:billing_baba/features/settings/data/tax_rate_sync.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
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
  }) async =>
      {'device_id': deviceId};

  @override
  Future<Map<String, dynamic>> status({
    required String deviceId,
    required String appVersion,
  }) async =>
      const {'schema_version': 1, 'protocol_version': 1};

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
  }) async =>
      pullPayload;
}

SyncCoordinator _coord({
  required _FakeSyncApi api,
  required SyncQueue queue,
  required SyncDeviceIdentity identity,
  required SyncMetadataStore metadata,
  required StorageService storage,
  required AppDatabase db,
}) {
  return SyncCoordinator(
    api: api,
    queue: queue,
    identity: identity,
    metadata: metadata,
    storage: storage,
    categorySync: CategorySync(db),
    partySync: PartySync(db),
    itemSync: ItemSync(db),
    unitSync: UnitSync(db),
    taxRateSync: TaxRateSync(db),
    godownSync: GodownSync(db),
    businessSettingsSync: BusinessSettingsSync(db),
  );
}

void main() {
  late StorageService storage;
  late AppDatabase db;
  late SyncQueue queue;
  late UnitLocalSource units;
  late UnitMasterRepository repo;
  late SyncMetadataStore metadata;
  late _FakeSyncApi api;
  late SyncCoordinator coordinator;
  late SyncState lastState;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-1',
    });
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(preferences: prefs);
    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(db);
    units = UnitLocalSource(db);
    metadata = SyncMetadataStore(storage);
    api = _FakeSyncApi();
    repo = UnitMasterRepository(
      local: units,
      syncQueue: queue,
      remote: InventoryRemoteDataSource(Dio()),
      businessIdReader: () =>
          storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
      deviceIdReader: () => '22222222-2222-2222-2222-222222222222',
    );
    final identity = SyncDeviceIdentity(
      storage,
      packageInfoLoader: () async => PackageInfo(
        appName: 'Billing Baba',
        packageName: 'billing_baba',
        version: '1.0.0',
        buildNumber: '1',
      ),
      platformName: () => 'test',
    );
    coordinator = _coord(
      api: api,
      queue: queue,
      identity: identity,
      metadata: metadata,
      storage: storage,
      db: db,
    );
    lastState = const SyncState(connectivity: SyncConnectivityStatus.online);
  });

  tearDown(() async {
    coordinator.dispose();
    await db.close();
  });

  Future<void> syncNow() async {
    var state = const SyncState(connectivity: SyncConnectivityStatus.online);
    final result = await coordinator.orchestrate(
      currentState: state,
      emit: (update) => state = update(state),
    );
    lastState = state;
    expect(result, isNotNull);
  }

  test('offline create/update/delete writes Drift + pending queue jobs',
      () async {
    final created = await repo.create(
      const CreateUnitRequest(name: 'Kilogram', shortName: 'kg'),
    );
    expect(created.name, 'Kilogram');
    expect((await units.listActive('biz-1')).map((u) => u.name), ['Kilogram']);
    var pending = await queue.listPending();
    expect(pending, hasLength(1));
    expect(pending.first.entityType, 'unit_definitions');
    expect(pending.first.operation, SyncQueueOperation.create);
    expect(SyncJob.domainOnly(pending.first.payload)['short_name'], 'kg');

    await repo.update(created.id, const UpdateUnitRequest(name: 'Kg'));
    pending = await queue.listPending();
    expect(pending, hasLength(2));
    expect(pending.last.operation, SyncQueueOperation.update);

    await repo.softDelete(created.id);
    pending = await queue.listPending();
    expect(pending, hasLength(3));
    expect(pending.last.operation, SyncQueueOperation.delete);
    expect(await units.listActive('biz-1'), isEmpty);
    expect((await units.getById(created.id))!.isDeleted, isTrue);
  });

  test('push accepted updates syncVersion and completes job', () async {
    final created = await repo.create(
      const CreateUnitRequest(name: 'Piece', shortName: 'pc'),
    );
    await syncNow();
    expect(await queue.pendingCount(), 0);
    expect((await units.getById(created.id))!.syncVersion, 3);
    expect(lastState.lastResultMessage, contains('push=1'));
  });

  test('push replayed completes job and applies ack meta', () async {
    final created = await repo.create(
      const CreateUnitRequest(name: 'Box', shortName: 'box'),
    );
    api.pushHandler = (body) {
      final mutationId = (body['mutations'] as List).first['mutation_id'];
      return {
        'accepted': <Map<String, dynamic>>[],
        'replayed': [
          {
            'mutation_id': mutationId,
            'sync_version': 5,
            'server_updated_at': DateTime.utc(2026, 7).toIso8601String(),
          },
        ],
        'conflicts': <Map<String, dynamic>>[],
        'errors': <Map<String, dynamic>>[],
      };
    };
    await syncNow();
    expect(await queue.pendingCount(), 0);
    expect((await units.getById(created.id))!.syncVersion, 5);
  });

  test('CONFLICT keeps local row and marks queue conflict', () async {
    final created = await repo.create(
      const CreateUnitRequest(name: 'LocalUnit', shortName: 'lu'),
    );
    api.pushHandler = (body) {
      final mutationId = (body['mutations'] as List).first['mutation_id'];
      return {
        'accepted': <Map<String, dynamic>>[],
        'replayed': <Map<String, dynamic>>[],
        'conflicts': [
          {
            'mutation_id': mutationId,
            'code': 'VERSION_CONFLICT',
            'server_payload': {'name': 'ServerUnit'},
            'server_sync_version': 9,
          },
        ],
        'errors': <Map<String, dynamic>>[],
      };
    };
    await syncNow();
    expect((await units.getById(created.id))!.name, 'LocalUnit');
    final jobs = await (db.select(db.syncQueue)
          ..where((t) => t.entityId.equals(created.id)))
        .get();
    expect(jobs.first.status, SyncQueueStatus.conflict.wire);
  });

  test('pull upserts, soft-deletes, and advances cursor', () async {
    await metadata.setPullCursor('cursor-start');
    await metadata.setBootstrappedAt(DateTime.utc(2026));
    await metadata.setLastServerSchemaVersion(1);
    const keepId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    const deleteId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    await units.upsertRow(
      id: deleteId,
      businessId: 'biz-1',
      name: 'Gone',
      shortName: 'g',
      syncVersion: 1,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    api.pullPayload = {
      'changes': [
        {
          'entity_type': 'unit_definitions',
          'entity_id': keepId,
          'sync_version': 2,
          'updated_at': DateTime.utc(2026, 8).toIso8601String(),
          'is_deleted': false,
          'payload': {
            'name': 'FromServer',
            'short_name': 'fs',
            'decimal_places': 0,
            'is_system': false,
            'is_active': true,
          },
        },
        {
          'entity_type': 'unit_definitions',
          'entity_id': deleteId,
          'sync_version': 4,
          'updated_at': DateTime.utc(2026, 8, 2).toIso8601String(),
          'is_deleted': true,
          'deleted_at': DateTime.utc(2026, 8, 2).toIso8601String(),
          'payload': {'name': 'Gone', 'short_name': 'g'},
        },
      ],
      'next_cursor': 'cursor-after-pull',
      'has_more': false,
    };
    await syncNow();
    expect((await units.getById(keepId))!.name, 'FromServer');
    expect((await units.getById(deleteId))!.isDeleted, isTrue);
    expect(metadata.pullCursor, 'cursor-after-pull');
  });

  test('units persist across DB reopen', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('bb-unit-persist-');
    final path = '${dir.path}/test.sqlite';
    Future<AppDatabase> openDb() async =>
        AppDatabase(NativeDatabase(File(path)));
    final db1 = await openDb();
    final queue1 = SyncQueue(db1);
    final units1 = UnitLocalSource(db1);
    final repo1 = UnitMasterRepository(
      local: units1,
      syncQueue: queue1,
      remote: InventoryRemoteDataSource(Dio()),
      businessIdReader: () => 'biz-1',
    );
    final created = await repo1.create(
      const CreateUnitRequest(name: 'Persisted', shortName: 'p'),
    );
    await db1.close();
    final db2 = await openDb();
    final units2 = UnitLocalSource(db2);
    final listed = await units2.listActive('biz-1');
    expect(listed.single.id, created.id);
    expect(listed.single.name, 'Persisted');
    expect((await SyncQueue(db2).listPending()).single.entityType,
        'unit_definitions');
    await db2.close();
    await dir.delete(recursive: true);
  });
}
