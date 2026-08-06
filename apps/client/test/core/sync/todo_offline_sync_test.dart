import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/tasks/data/todo_local_source.dart';
import 'package:billing_baba/features/tasks/data/todo_master_repository.dart';
import 'package:billing_baba/features/tasks/data/todo_repository.dart';
import 'package:billing_baba/features/tasks/data/todo_sync.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSyncApi extends SyncApi {
  _FakeSyncApi() : super(Dio());

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
    final mutations = (body['mutations'] as List?) ?? const [];
    return {
      'accepted': [
        for (final m in mutations)
          if (m is Map)
            {
              'mutation_id': m['mutation_id'],
              'sync_version': 2,
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
  late TodoLocalSource local;
  late TodoMasterRepository repo;
  late SyncCoordinator coordinator;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lastOpenedBusinessId: 'biz-1',
    });
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(preferences: prefs);
    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(db);
    local = TodoLocalSource(db);
    repo = TodoMasterRepository(
      local: local,
      syncQueue: queue,
      remote: TodoRepository(Dio()),
      storage: storage,
      businessIdReader: () =>
          storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
      deviceIdReader: () => '22222222-2222-2222-2222-222222222222',
    );

    final metadata = SyncMetadataStore(storage);
    final api = _FakeSyncApi();
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

    coordinator = SyncCoordinator(
      api: api,
      queue: queue,
      identity: identity,
      metadata: metadata,
      storage: storage,
      todoSync: TodoSync(db),
    );
  });

  tearDown(() async {
    coordinator.dispose();
    await db.close();
  });

  test('offline create writes Drift + pending todos queue job', () async {
    final created = await repo.create(title: 'Call supplier');
    expect(created.title, 'Call supplier');

    final listed = await local.listActive('biz-1');
    expect(listed.map((t) => t.title), ['Call supplier']);

    final pending = await queue.listPending();
    expect(pending, hasLength(1));
    expect(pending.first.entityType, 'todos');
    expect(pending.first.operation, SyncQueueOperation.create);
    expect(SyncJob.domainOnly(pending.first.payload)['title'], 'Call supplier');
  });

  test('update and delete enqueue row mutations', () async {
    final created = await repo.create(title: 'GST filing');
    final updated = await repo.update(
      created.copyWith(title: 'GST filing updated', isCompleted: true),
    );
    expect(updated.isCompleted, isTrue);

    await repo.softDelete(created.id);
    final pending = await queue.listPending();
    expect(pending.map((j) => j.operation), [
      SyncQueueOperation.create,
      SyncQueueOperation.update,
      SyncQueueOperation.delete,
    ]);
    expect(await local.listActive('biz-1'), isEmpty);
  });

  test('migrates legacy SharedPreferences tasks into Drift', () async {
    await storage.write(
      '${StorageKeys.dashboardTasks}_biz-1',
      '[{"id":"legacy-1","title":"Legacy task","is_completed":false,'
      '"created_at":"2026-01-01T00:00:00.000","updated_at":"2026-01-01T00:00:00.000"}]',
    );

    final tasks = await repo.listActive();
    expect(tasks.map((t) => t.title), ['Legacy task']);
    expect(storage.read('${StorageKeys.dashboardTasks}_biz-1'), isNull);
    expect(storage.read(StorageKeys.dashboardTasksMigratedFor('biz-1')), 'true');

    final pending = await queue.listPending();
    expect(pending, hasLength(1));
    expect(pending.first.entityType, 'todos');
  });
}
