import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/network/sync_api.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/category_sync.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSyncApi extends SyncApi {
  _FakeSyncApi() : super(Dio());

  int registerCalls = 0;
  int statusCalls = 0;
  int pushCalls = 0;
  int pullCalls = 0;

  Object? registerError;
  Object? statusError;
  Object? pushError;
  Object? pullError;

  Map<String, dynamic> statusPayload = const {
    'schema_version': 1,
    'protocol_version': 1,
  };

  Map<String, dynamic> Function(Map<String, dynamic> body)? pushHandler;
  Map<String, dynamic> pullPayload = const {
    'changes': <Map<String, dynamic>>[],
    'next_cursor': 'cursor-next',
    'has_more': false,
  };

  Map<String, dynamic>? lastPushBody;
  String? lastPullCursor;
  String? lastPullEntityTypes;

  @override
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String platform,
    required String appVersion,
    required String deviceName,
  }) async {
    registerCalls++;
    if (registerError != null) throw registerError!;
    return {'device_id': deviceId};
  }

  @override
  Future<Map<String, dynamic>> status({
    required String deviceId,
    required String appVersion,
  }) async {
    statusCalls++;
    if (statusError != null) throw statusError!;
    return statusPayload;
  }

  @override
  Future<Map<String, dynamic>> push({
    required String deviceId,
    required String appVersion,
    required Map<String, dynamic> body,
  }) async {
    pushCalls++;
    lastPushBody = body;
    if (pushError != null) throw pushError!;
    if (pushHandler != null) return pushHandler!(body);
    final mutations = (body['mutations'] as List?) ?? const [];
    return {
      'accepted': [
        for (final m in mutations)
          if (m is Map)
            {
              'mutation_id': m['mutation_id'],
              'sync_version': 1,
              'server_updated_at': DateTime.utc(2026, 1, 2).toIso8601String(),
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
  }) async {
    pullCalls++;
    lastPullCursor = cursor;
    lastPullEntityTypes = entityTypes;
    if (pullError != null) throw pullError!;
    return pullPayload;
  }
}

void main() {
  late StorageService storage;
  late AppDatabase db;
  late SyncQueue queue;
  late SyncMetadataStore metadata;
  late _FakeSyncApi api;
  late SyncCoordinator coordinator;
  late List<SyncLifecycleState> lifecycles;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(preferences: prefs);
    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueue(db);
    metadata = SyncMetadataStore(storage);
    api = _FakeSyncApi();

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
      categorySync: CategorySync(db),
    );

    lifecycles = <SyncLifecycleState>[];
  });

  tearDown(() async {
    coordinator.dispose();
    await db.close();
  });

  Future<SyncState> runOrchestrate({
    SyncConnectivityStatus connectivity = SyncConnectivityStatus.online,
  }) async {
    var state = SyncState(connectivity: connectivity);
    await coordinator.orchestrate(
      currentState: state,
      emit: (update) {
        state = update(state);
        lifecycles.add(state.lifecycle);
      },
    );
    return state;
  }

  test('orchestrate offline short-circuits without network', () async {
    final state = await runOrchestrate(
      connectivity: SyncConnectivityStatus.offline,
    );
    expect(api.registerCalls, 0);
    expect(api.statusCalls, 0);
    expect(state.lifecycle, SyncLifecycleState.offline);
  });

  test('bootstrap pulls from epoch then marks bootstrapped', () async {
    await storage.write(StorageKeys.lastOpenedBusinessId, 'biz-1');

    final state = await runOrchestrate();

    expect(api.registerCalls, 1);
    expect(api.statusCalls, 1);
    expect(api.pushCalls, 0);
    // bootstrap pull + steady-state pull
    expect(api.pullCalls, 2);
    expect(api.lastPullEntityTypes, 'categories');
    expect(metadata.pullCursor, isNotNull);
    expect(metadata.bootstrappedAt, isNotNull);
    expect(state.lifecycle, SyncLifecycleState.idle);
    expect(state.lastResultMessage, contains('Sync complete'));
  });

  test('ready state pushes category jobs and skips non-category rows', () async {
    await storage.write(StorageKeys.lastOpenedBusinessId, 'biz-1');
    await storage.write(StorageKeys.syncPullCursor, 'cursor-abc');
    await storage.write(
      StorageKeys.syncBootstrappedAt,
      DateTime.utc(2026).toIso8601String(),
    );
    await storage.write(StorageKeys.syncLastServerSchemaVersion, '1');

    await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'parties',
      entityId: '00000000-0000-0000-0000-0000000000p1',
      operation: SyncQueueOperation.create,
      payload: {'name': 'A'},
    );

    final catJob = await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'categories',
      entityId: '11111111-1111-1111-1111-111111111111',
      operation: SyncQueueOperation.create,
      payload: {'name': 'Retail'},
    );

    await db.into(db.categoriesLocal).insert(
          CategoriesLocalCompanion.insert(
            id: '11111111-1111-1111-1111-111111111111',
            businessId: 'biz-1',
            name: 'Retail',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    final state = await runOrchestrate();

    expect(api.pushCalls, 1);
    expect(api.pullCalls, 1);
    final mutations = api.lastPushBody!['mutations'] as List;
    expect(mutations, hasLength(1));
    expect(mutations.first['entity_type'], 'categories');
    expect(mutations.first['mutation_id'], catJob.mutationId);
    expect(mutations.first['payload'], {'name': 'Retail'});
    expect(
      mutations.first.containsKey(SyncJob.baseSyncVersionKey),
      isFalse,
    );

    expect(await queue.pendingCount(), 1); // parties still pending
    final row = await (db.select(db.categoriesLocal)
          ..where(
            (t) => t.id.equals('11111111-1111-1111-1111-111111111111'),
          ))
        .getSingle();
    expect(row.syncVersion, 1);
    expect(state.lastResultMessage, contains('push=1'));
  });

  test('401 on register → needsAuthentication', () async {
    api.registerError = DioException(
      requestOptions: RequestOptions(path: '/sync/devices'),
      response: Response(
        requestOptions: RequestOptions(path: '/sync/devices'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

    final state = await runOrchestrate();

    expect(state.lifecycle, SyncLifecycleState.needsAuthentication);
  });

  test('network error on status → failed', () async {
    api.statusError = DioException(
      requestOptions: RequestOptions(path: '/sync/status'),
      type: DioExceptionType.connectionError,
    );

    await storage.write(StorageKeys.lastOpenedBusinessId, 'biz-1');
    final state = await runOrchestrate();

    expect(state.lifecycle, SyncLifecycleState.failed);
  });
}
