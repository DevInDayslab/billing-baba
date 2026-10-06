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
import 'package:billing_baba/features/settings/data/tax_rate_sync.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
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
      partySync: PartySync(db),
      itemSync: ItemSync(db),
      unitSync: UnitSync(db),
      taxRateSync: TaxRateSync(db),
      godownSync: GodownSync(db),
      businessSettingsSync: BusinessSettingsSync(db),
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
    expect(
      api.lastPullEntityTypes,
      'categories,brands,parties,items,unit_definitions,tax_rates,godowns,business_settings,sales_documents,sales_document_lines,purchase_documents,purchase_document_lines,leads,lead_activities,contacts,contact_activities,deals,expenses,expense_categories,stock_levels',
    );
    // Bootstrap starts from epoch cursor (opaque base64), then stores next_cursor.
    expect(api.lastPullCursor, isNotNull);
    expect(metadata.pullCursor, isNotNull);
    expect(metadata.bootstrappedAt, isNotNull);
    expect(state.lifecycle, SyncLifecycleState.idle);
    expect(state.lastResultMessage, contains('Sync complete'));
  });

  test('ready state pushes category, party, and item row jobs', () async {
    await storage.write(StorageKeys.lastOpenedBusinessId, 'biz-1');
    await storage.write(StorageKeys.syncPullCursor, 'cursor-abc');
    await storage.write(
      StorageKeys.syncBootstrappedAt,
      DateTime.utc(2026).toIso8601String(),
    );
    await storage.write(StorageKeys.syncLastServerSchemaVersion, '1');

    final partyJob = await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'parties',
      entityId: '00000000-0000-0000-0000-0000000000p1',
      operation: SyncQueueOperation.create,
      payload: {'name': 'A', 'mobile': '9000000000', 'party_type': 'customer'},
    );

    final catJob = await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'categories',
      entityId: '11111111-1111-1111-1111-111111111111',
      operation: SyncQueueOperation.create,
      payload: {'name': 'Retail'},
    );

    final itemJob = await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'items',
      entityId: '22222222-2222-2222-2222-222222222222',
      operation: SyncQueueOperation.create,
      payload: {'name': 'Widget', 'base_unit': 'piece'},
    );

    await db
        .into(db.categoriesLocal)
        .insert(
          CategoriesLocalCompanion.insert(
            id: '11111111-1111-1111-1111-111111111111',
            businessId: 'biz-1',
            name: 'Retail',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    await db
        .into(db.partiesLocal)
        .insert(
          PartiesLocalCompanion.insert(
            id: '00000000-0000-0000-0000-0000000000p1',
            businessId: 'biz-1',
            name: 'A',
            mobile: const Value('9000000000'),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    await db
        .into(db.itemsLocal)
        .insert(
          ItemsLocalCompanion.insert(
            id: '22222222-2222-2222-2222-222222222222',
            businessId: 'biz-1',
            name: 'Widget',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    final state = await runOrchestrate();

    expect(api.pushCalls, 1);
    expect(api.pullCalls, 1);
    expect(
      api.lastPullEntityTypes,
      'categories,brands,parties,items,unit_definitions,tax_rates,godowns,business_settings,sales_documents,sales_document_lines,purchase_documents,purchase_document_lines,leads,lead_activities,contacts,contact_activities,deals,expenses,expense_categories,stock_levels',
    );
    final mutations = api.lastPushBody!['mutations'] as List;
    expect(mutations, hasLength(3));
    final types = mutations.map((m) => m['entity_type']).toSet();
    expect(types, {'categories', 'parties', 'items'});
    expect(
      mutations.map((m) => m['mutation_id']),
      containsAll([catJob.mutationId, partyJob.mutationId, itemJob.mutationId]),
    );

    expect(await queue.pendingCount(), 0);
    final catRow =
        await (db.select(db.categoriesLocal)..where(
              (t) => t.id.equals('11111111-1111-1111-1111-111111111111'),
            ))
            .getSingle();
    expect(catRow.syncVersion, 1);
    final partyRow =
        await (db.select(db.partiesLocal)..where(
              (t) => t.id.equals('00000000-0000-0000-0000-0000000000p1'),
            ))
            .getSingle();
    expect(partyRow.syncVersion, 1);
    final itemRow =
        await (db.select(db.itemsLocal)..where(
              (t) => t.id.equals('22222222-2222-2222-2222-222222222222'),
            ))
            .getSingle();
    expect(itemRow.syncVersion, 1);
    expect(state.lastResultMessage, contains('push=3'));
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

  test('unsupported entity types are skipped in push batch', () async {
    await storage.write(StorageKeys.lastOpenedBusinessId, 'biz-1');
    await storage.write(StorageKeys.syncPullCursor, 'cursor-abc');
    await storage.write(
      StorageKeys.syncBootstrappedAt,
      DateTime.utc(2026).toIso8601String(),
    );
    await storage.write(StorageKeys.syncLastServerSchemaVersion, '1');

    api.statusPayload = {
      'schema_version': 1,
      'protocol_version': 1,
      'supported_entities': [
        'categories',
        'parties',
        'items',
        'unit_definitions',
        'tax_rates',
        'godowns',
        'business_settings',
        'sales_documents',
        'sales_document_lines',
        'purchase_documents',
        'purchase_document_lines',
      ],
    };

    final leadJob = await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'leads',
      entityId: '33333333-3333-3333-3333-333333333333',
      operation: SyncQueueOperation.create,
      payload: {'name': 'Prospect'},
    );

    final partyJob = await queue.enqueueRowMutation(
      businessId: 'biz-1',
      entityType: 'parties',
      entityId: '00000000-0000-0000-0000-0000000000p1',
      operation: SyncQueueOperation.create,
      payload: {'name': 'A', 'mobile': '9000000000', 'party_type': 'customer'},
    );

    await db
        .into(db.partiesLocal)
        .insert(
          PartiesLocalCompanion.insert(
            id: '00000000-0000-0000-0000-0000000000p1',
            businessId: 'biz-1',
            name: 'A',
            mobile: const Value('9000000000'),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    final state = await runOrchestrate();

    expect(api.pushCalls, 1);
    final mutations = api.lastPushBody!['mutations'] as List;
    expect(mutations, hasLength(1));
    expect(mutations.first['entity_type'], 'parties');
    expect(mutations.first['mutation_id'], partyJob.mutationId);

    final pending = await queue.listPending(businessId: 'biz-1');
    expect(pending, hasLength(1));
    expect(pending.first.mutationId, leadJob.mutationId);
    expect(pending.first.entityType, 'leads');
    expect(state.lastResultMessage, contains('push=1'));
  });
}
