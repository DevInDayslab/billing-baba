import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/engine/bootstrap_decision.dart';
import 'package:billing_baba/core/sync/engine/device_identity.dart';
import 'package:billing_baba/core/sync/engine/sync_coordinator.dart';
import 'package:billing_baba/core/sync/engine/sync_metadata_store.dart';
import 'package:billing_baba/core/sync/engine/sync_orchestration_phase.dart';
import 'package:billing_baba/core/sync/engine/sync_plan.dart';
import 'package:billing_baba/core/sync/models/sync_job_payload_meta.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/core/sync/models/sync_state.dart';
import 'package:billing_baba/core/sync/offline/category_sync_applier.dart';
import 'package:billing_baba/core/sync/queue/drift_sync_queue_repository.dart';
import 'package:billing_baba/core/sync/queue/sync_queue_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTransport implements SyncCoordinatorTransport {
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
  late SyncQueueService queue;
  late SyncMetadataStore metadata;
  late _FakeTransport transport;
  late SyncCoordinator coordinator;
  late List<SyncOrchestrationPhase> phases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = StorageService(preferences: prefs);
    db = AppDatabase(NativeDatabase.memory());
    queue = SyncQueueService(DriftSyncQueueRepository(db));
    metadata = SyncMetadataStore(storage);
    transport = _FakeTransport();

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
      transport: transport,
      queueService: queue,
      identity: identity,
      metadata: metadata,
      storage: storage,
      categoryApplier: CategorySyncApplier(db),
    );

    phases = <SyncOrchestrationPhase>[];
  });

  tearDown(() async {
    coordinator.dispose();
    await db.close();
  });

  Future<void> runOrchestrate({
    SyncConnectivityStatus connectivity = SyncConnectivityStatus.online,
  }) async {
    var state = SyncState(connectivity: connectivity);
    await coordinator.orchestrate(
      currentState: state,
      emit: (update) {
        state = update(state);
        phases.add(state.orchestrationPhase);
      },
    );
  }

  test('BootstrapDecision needs bootstrap without cursor', () {
    final decision = BootstrapDecision.evaluate(
      businessId: 'biz-1',
      pullCursor: null,
      bootstrappedAt: null,
      localSchemaVersion: 1,
      lastServerSchemaVersion: null,
      serverSchemaVersion: 1,
    );
    expect(decision.needsBootstrap, isTrue);
    expect(decision.reason, 'no_local_cursor');
  });

  test('BootstrapDecision ready when cursor present', () {
    final decision = BootstrapDecision.evaluate(
      businessId: 'biz-1',
      pullCursor: 'cursor-1',
      bootstrappedAt: DateTime.utc(2026),
      localSchemaVersion: 1,
      lastServerSchemaVersion: 1,
      serverSchemaVersion: 1,
    );
    expect(decision.needsBootstrap, isFalse);
  });

  test('orchestrate offline short-circuits without transport', () async {
    await runOrchestrate(connectivity: SyncConnectivityStatus.offline);
    expect(transport.registerCalls, 0);
    expect(transport.statusCalls, 0);
    expect(
      coordinator.currentSession?.terminalPhase,
      SyncOrchestrationPhase.offline,
    );
    expect(coordinator.currentSession?.rowsUploaded, 0);
  });

  test('minimal bootstrap seeds cursor then push/pull categories', () async {
    await storage.write(StorageKeys.lastOpenedBusinessId, 'biz-1');

    await runOrchestrate();

    expect(transport.registerCalls, 1);
    expect(transport.statusCalls, 1);
    expect(transport.pushCalls, 0);
    expect(transport.pullCalls, 1);
    expect(transport.lastPullEntityTypes, 'categories');
    expect(metadata.pullCursor, isNotNull);
    expect(metadata.bootstrappedAt, isNotNull);

    final plan = coordinator.currentPlan!;
    expect(plan.needsBootstrap, isFalse);
    expect(plan.steps, contains(SyncPlanStep.pushQueue));
    expect(plan.steps, contains(SyncPlanStep.pullChanges));
    expect(plan.steps, isNot(contains(SyncPlanStep.bootstrap)));
    expect(
      coordinator.currentSession?.terminalPhase,
      SyncOrchestrationPhase.ready,
    );
  });

  test('ready plan pushes category jobs and skips non-category rows', () async {
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

    await runOrchestrate();

    expect(transport.pushCalls, 1);
    expect(transport.pullCalls, 1);
    final mutations = transport.lastPushBody!['mutations'] as List;
    expect(mutations, hasLength(1));
    expect(mutations.first['entity_type'], 'categories');
    expect(mutations.first['mutation_id'], catJob.mutationId);
    expect(mutations.first['payload'], {'name': 'Retail'});
    expect(
      mutations.first.containsKey(SyncJobPayloadMeta.baseSyncVersionKey),
      isFalse,
    );

    expect(await queue.pendingCount(), 1); // parties still pending
    final row = await (db.select(db.categoriesLocal)
          ..where(
            (t) => t.id.equals('11111111-1111-1111-1111-111111111111'),
          ))
        .getSingle();
    expect(row.syncVersion, 1);
    expect(coordinator.currentSession?.rowsUploaded, 1);
  });

  test('401 on register → authenticationFailed', () async {
    transport.registerError = DioException(
      requestOptions: RequestOptions(path: '/sync/devices'),
      response: Response(
        requestOptions: RequestOptions(path: '/sync/devices'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

    await runOrchestrate();

    expect(
      coordinator.currentSession?.terminalPhase,
      SyncOrchestrationPhase.authenticationFailed,
    );
    expect(coordinator.currentSession?.failures, 1);
  });

  test('network error on status → serverUnavailable', () async {
    transport.statusError = DioException(
      requestOptions: RequestOptions(path: '/sync/status'),
      type: DioExceptionType.connectionError,
    );

    await storage.write(StorageKeys.lastOpenedBusinessId, 'biz-1');
    await runOrchestrate();

    expect(
      coordinator.currentSession?.terminalPhase,
      SyncOrchestrationPhase.serverUnavailable,
    );
  });
}
