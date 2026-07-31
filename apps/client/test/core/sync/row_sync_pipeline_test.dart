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
import 'package:billing_baba/features/inventory/data/category_local_source.dart';
import 'package:billing_baba/features/inventory/data/category_sync.dart';
import 'package:billing_baba/features/inventory/data/inventory_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_movement_projector.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_local_source.dart';
import 'package:billing_baba/features/inventory/data/item_master_repository.dart';
import 'package:billing_baba/features/inventory/data/item_sync.dart';
import 'package:billing_baba/features/inventory/models/requests/category_requests.dart';
import 'package:billing_baba/features/inventory/models/requests/item_requests.dart';
import 'package:billing_baba/features/parties/data/party_local_source.dart';
import 'package:billing_baba/features/parties/data/party_master_repository.dart';
import 'package:billing_baba/features/parties/data/party_repository.dart';
import 'package:billing_baba/features/parties/data/party_sync.dart';
import 'package:billing_baba/features/parties/models/create_party_request.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

/// Isolated prefs so multi-device harnesses do not share sync metadata.
class _MapStorage extends StorageService {
  _MapStorage(this._map) : super(preferences: null);

  final Map<String, String> _map;

  @override
  String? read(String key) => _map[key];

  @override
  Future<void> write(String key, String value) async {
    _map[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _map.remove(key);
  }
}

/// Shared in-memory row store simulating multi-device sync server behavior.
class _InMemoryRowServer {
  final _rows = <String, Map<String, dynamic>>{};
  final _seenMutations = <String, Map<String, dynamic>>{};
  var _seq = 0;

  String _key(String type, String id) => '$type:$id';

  Map<String, dynamic> push({
    required String deviceId,
    required Map<String, dynamic> body,
  }) {
    final accepted = <Map<String, dynamic>>[];
    final replayed = <Map<String, dynamic>>[];
    final conflicts = <Map<String, dynamic>>[];
    final mutations = (body['mutations'] as List?) ?? const [];

    for (final raw in mutations) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final mutationId = m['mutation_id']?.toString() ?? '';
      final entityType = m['entity_type']?.toString() ?? '';
      final entityId = m['entity_id']?.toString() ?? '';
      final operation = m['operation']?.toString() ?? 'create';
      final base = (m['base_sync_version'] as num?)?.toInt() ?? 0;
      final payload = m['payload'] is Map
          ? Map<String, dynamic>.from(m['payload'] as Map)
          : <String, dynamic>{};

      if (_seenMutations.containsKey(mutationId)) {
        final prior = _seenMutations[mutationId]!;
        replayed.add({
          'mutation_id': mutationId,
          'sync_version': prior['sync_version'],
          'server_updated_at': prior['server_updated_at'],
          'idempotent_replay': true,
        });
        continue;
      }

      final key = _key(entityType, entityId);
      final existing = _rows[key];
      final currentVersion = (existing?['sync_version'] as num?)?.toInt() ?? 0;

      if (operation != 'create' && existing != null && base != currentVersion) {
        conflicts.add({
          'mutation_id': mutationId,
          'code': 'VERSION_CONFLICT',
          'server_payload': existing['payload'],
          'server_sync_version': currentVersion,
        });
        continue;
      }

      _seq += 1;
      final syncVersion = currentVersion + 1;
      final updatedAt = DateTime.utc(2026)
          .add(Duration(seconds: _seq))
          .toIso8601String();
      final isDelete = operation == 'delete';
      _rows[key] = {
        'entity_type': entityType,
        'entity_id': entityId,
        'sync_version': syncVersion,
        'updated_at': updatedAt,
        'is_deleted': isDelete,
        if (isDelete) 'deleted_at': updatedAt,
        'payload': isDelete
            ? (existing?['payload'] ?? payload)
            : {...?existing?['payload'] as Map<String, dynamic>?, ...payload},
        'device_id': deviceId,
        '_seq': _seq,
      };
      final ack = {
        'mutation_id': mutationId,
        'sync_version': syncVersion,
        'server_updated_at': updatedAt,
        'entity_id': entityId,
      };
      _seenMutations[mutationId] = ack;
      accepted.add(ack);
    }

    return {
      'accepted': accepted,
      'replayed': replayed,
      'conflicts': conflicts,
      'errors': <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> pull({
    required String cursor,
    String? entityTypes,
  }) {
    final allowed = entityTypes
            ?.split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet() ??
        {'categories', 'parties', 'items'};
    final afterSeq = int.tryParse(cursor.replaceFirst('c-', '')) ?? 0;
    final changes = _rows.values
        .where((r) => allowed.contains(r['entity_type']))
        .where((r) => ((r['_seq'] as num?)?.toInt() ?? 0) > afterSeq)
        .toList()
      ..sort(
        (a, b) =>
            ((a['_seq'] as num).toInt()).compareTo((b['_seq'] as num).toInt()),
      );

    final nextSeq = changes.isEmpty
        ? afterSeq
        : (changes.last['_seq'] as num).toInt();
    return {
      'changes': [
        for (final r in changes)
          {
            'entity_type': r['entity_type'],
            'entity_id': r['entity_id'],
            'sync_version': r['sync_version'],
            'updated_at': r['updated_at'],
            'is_deleted': r['is_deleted'] == true,
            if (r['deleted_at'] != null) 'deleted_at': r['deleted_at'],
            'payload': r['payload'],
            'device_id': r['device_id'],
          },
      ],
      'next_cursor': 'c-$nextSeq',
      'has_more': false,
    };
  }
}

class _ServerBackedSyncApi extends SyncApi {
  _ServerBackedSyncApi(this._server, {required this.deviceId}) : super(Dio());

  final _InMemoryRowServer _server;
  final String deviceId;
  int pullCalls = 0;
  String? lastPullEntityTypes;
  String? lastPullCursor;

  /// When true, pull returns no changes (isolates push conflict behavior).
  bool suppressPullChanges = false;

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
  }) async =>
      _server.push(deviceId: deviceId, body: body);

  @override
  Future<Map<String, dynamic>> pull({
    required String deviceId,
    required String appVersion,
    required String cursor,
    int? limit,
    String? entityTypes,
  }) async {
    pullCalls += 1;
    lastPullCursor = cursor;
    lastPullEntityTypes = entityTypes;
    if (suppressPullChanges) {
      return {
        'changes': <Map<String, dynamic>>[],
        'next_cursor': cursor,
        'has_more': false,
      };
    }
    return _server.pull(cursor: cursor, entityTypes: entityTypes);
  }
}

class _DeviceHarness {
  _DeviceHarness({
    required this.label,
    required this.deviceId,
    required this.db,
    required this.storage,
    required this.queue,
    required this.categories,
    required this.parties,
    required this.items,
    required this.categoryRepo,
    required this.partyRepo,
    required this.itemRepo,
    required this.metadata,
    required this.api,
    required this.coordinator,
  });

  final String label;
  final String deviceId;
  final AppDatabase db;
  final StorageService storage;
  final SyncQueue queue;
  final CategoryLocalSource categories;
  final PartyLocalSource parties;
  final ItemLocalSource items;
  final InventoryRepository categoryRepo;
  final PartyMasterRepository partyRepo;
  final ItemMasterRepository itemRepo;
  final SyncMetadataStore metadata;
  final _ServerBackedSyncApi api;
  final SyncCoordinator coordinator;

  Future<SyncState> sync() async {
    var state = const SyncState(connectivity: SyncConnectivityStatus.online);
    await coordinator.orchestrate(
      currentState: state,
      emit: (update) => state = update(state),
    );
    return state;
  }

  Future<void> dispose() async {
    coordinator.dispose();
    await db.close();
  }
}

Future<_DeviceHarness> _openDevice({
  required String label,
  required String deviceId,
  required _InMemoryRowServer server,
}) async {
  final storage = _MapStorage({
    StorageKeys.lastOpenedBusinessId: 'biz-1',
    StorageKeys.syncDeviceId: deviceId,
  });
  final db = AppDatabase(NativeDatabase.memory());
  final queue = SyncQueue(db);
  final categories = CategoryLocalSource(db);
  final parties = PartyLocalSource(db);
  final items = ItemLocalSource(db);
  final remote = InventoryRemoteDataSource(Dio());

  final categoryRepo = InventoryRepository(
    remote: remote,
    local: DriftInventoryLocalDataSource(categories),
    syncQueue: queue,
    businessIdReader: () => 'biz-1',
    deviceIdReader: () => deviceId,
    stockLocal: InventoryStockLocalDataSource(db),
    movementProjector: InventoryMovementProjector(db),
    items: ItemMasterRepository(
      local: items,
      syncQueue: queue,
      remote: remote,
      businessIdReader: () => 'biz-1',
      deviceIdReader: () => deviceId,
    ),
  );
  final partyRepo = PartyMasterRepository(
    local: parties,
    syncQueue: queue,
    remote: PartyRepository(Dio()),
    businessIdReader: () => 'biz-1',
    deviceIdReader: () => deviceId,
  );
  final itemRepo = ItemMasterRepository(
    local: items,
    syncQueue: queue,
    remote: remote,
    businessIdReader: () => 'biz-1',
    deviceIdReader: () => deviceId,
  );

  final metadata = SyncMetadataStore(storage);
  final api = _ServerBackedSyncApi(server, deviceId: deviceId);
  final identity = SyncDeviceIdentity(
    storage,
    uuid: const Uuid(),
    packageInfoLoader: () async => PackageInfo(
      appName: 'Billing Baba',
      packageName: 'billing_baba',
      version: '1.0.0',
      buildNumber: '1',
    ),
    platformName: () => label,
  );

  final coordinator = SyncCoordinator(
    api: api,
    queue: queue,
    identity: identity,
    metadata: metadata,
    storage: storage,
    categorySync: CategorySync(db),
    partySync: PartySync(db),
    itemSync: ItemSync(db),
  );

  return _DeviceHarness(
    label: label,
    deviceId: deviceId,
    db: db,
    storage: storage,
    queue: queue,
    categories: categories,
    parties: parties,
    items: items,
    categoryRepo: categoryRepo,
    partyRepo: partyRepo,
    itemRepo: itemRepo,
    metadata: metadata,
    api: api,
    coordinator: coordinator,
  );
}

void main() {
  late _InMemoryRowServer server;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    server = _InMemoryRowServer();
  });

  test('PART1 fresh bootstrap downloads categories+parties+items into Drift',
      () async {
    // Seed server as if another device already pushed masters.
    server.push(
      deviceId: 'seed-device',
      body: {
        'mutations': [
          {
            'mutation_id': const Uuid().v4(),
            'entity_type': 'categories',
            'entity_id': '11111111-1111-1111-1111-111111111111',
            'operation': 'create',
            'base_sync_version': 0,
            'payload': {'name': 'Retail'},
          },
          {
            'mutation_id': const Uuid().v4(),
            'entity_type': 'parties',
            'entity_id': '22222222-2222-2222-2222-222222222222',
            'operation': 'create',
            'base_sync_version': 0,
            'payload': {
              'name': 'Acme',
              'mobile': '9000000001',
              'party_type': 'customer',
            },
          },
          {
            'mutation_id': const Uuid().v4(),
            'entity_type': 'items',
            'entity_id': '33333333-3333-3333-3333-333333333333',
            'operation': 'create',
            'base_sync_version': 0,
            'payload': {
              'name': 'Widget',
              'base_unit': 'piece',
              'item_type': 'product',
              'has_stock_tracking': true,
              'sale_price': '10',
              'purchase_price': '8',
              'is_mrp_only': false,
            },
          },
        ],
      },
    );

    final android = await _openDevice(
      label: 'android',
      deviceId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      server: server,
    );
    addTearDown(android.dispose);

    expect(android.metadata.bootstrappedAt, isNull);
    expect(android.metadata.pullCursor, isNull);

    final state = await android.sync();

    expect(state.lifecycle, SyncLifecycleState.idle);
    expect(android.metadata.bootstrappedAt, isNotNull);
    expect(android.metadata.pullCursor, isNotNull);
    expect(android.api.lastPullEntityTypes, 'categories,brands,parties,items,unit_definitions,tax_rates,godowns,business_settings,sales_documents,sales_document_lines,purchase_documents,purchase_document_lines,leads,lead_activities,contacts,contact_activities,deals,expenses,expense_categories,stock_levels');

    final cats = await android.categories.listActive('biz-1');
    final parties = await android.parties.listActive('biz-1');
    final items = await android.items.listActive('biz-1');
    expect(cats.map((c) => c.name), ['Retail']);
    expect(parties.map((p) => p.name), ['Acme']);
    expect(items.map((i) => i.name), ['Widget']);
    expect(state.lastResultMessage, contains('pull='));
  });

  test('PART2 multi-device create → pull → edit → pull → soft-delete',
      () async {
    final desktop = await _openDevice(
      label: 'macos',
      deviceId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      server: server,
    );
    final android = await _openDevice(
      label: 'android',
      deviceId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      server: server,
    );
    addTearDown(desktop.dispose);
    addTearDown(android.dispose);

    // Desktop creates masters offline-first.
    final cat = await desktop.categoryRepo.createCategory(
      const CreateCategoryRequest(name: 'Electronics'),
    );
    final party = await desktop.partyRepo.create(
      const CreatePartyRequest(name: 'Vendor Co', mobile: '9111111111'),
    );
    final item = await desktop.itemRepo.create(
      const CreateItemRequest(name: 'Cable', baseUnit: 'piece'),
    );
    expect(await desktop.queue.pendingCount(), 3);

    final desktopPush = await desktop.sync();
    expect(await desktop.queue.pendingCount(), 0);
    expect(desktopPush.lastResultMessage, contains('push=3'));
    expect(desktop.metadata.bootstrappedAt, isNotNull);

    // Android bootstraps and receives all three.
    final androidBoot = await android.sync();
    expect(androidBoot.lifecycle, SyncLifecycleState.idle);
    expect(
      (await android.categories.listActive('biz-1')).map((c) => c.name),
      ['Electronics'],
    );
    expect(
      (await android.parties.listActive('biz-1')).map((p) => p.name),
      ['Vendor Co'],
    );
    expect(
      (await android.items.listActive('biz-1')).map((i) => i.name),
      ['Cable'],
    );

    // Android edits all three.
    await android.categoryRepo.updateCategory(
      cat.id,
      const UpdateCategoryRequest(name: 'Electronics++'),
    );
    await android.partyRepo.update(
      party.id,
      const UpdatePartyRequest(name: 'Vendor Co Pvt'),
    );
    await android.itemRepo.update(
      item.id,
      const UpdateItemRequest(name: 'Cable XL'),
    );
    await android.sync();
    expect(await android.queue.pendingCount(), 0);

    // Desktop pulls edits.
    await desktop.sync();
    expect((await desktop.categories.getById(cat.id))!.name, 'Electronics++');
    expect((await desktop.parties.getById(party.id))!.name, 'Vendor Co Pvt');
    expect((await desktop.items.getById(item.id))!.name, 'Cable XL');

    // Desktop soft-deletes; Android pulls soft deletes.
    await desktop.categoryRepo.deleteCategory(cat.id);
    await desktop.partyRepo.softDelete(party.id);
    await desktop.itemRepo.softDelete(item.id);
    await desktop.sync();
    await android.sync();

    expect((await android.categories.getById(cat.id))!.isDeleted, isTrue);
    expect((await android.parties.getById(party.id))!.isDeleted, isTrue);
    expect((await android.items.getById(item.id))!.isDeleted, isTrue);
    expect(await android.categories.listActive('biz-1'), isEmpty);
    expect(await android.parties.listActive('biz-1'), isEmpty);
    expect(await android.items.listActive('biz-1'), isEmpty);
  });

  test('PART3 conflict keeps local Drift and marks queue conflict', () async {
    final desktop = await _openDevice(
      label: 'macos',
      deviceId: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
      server: server,
    );
    final android = await _openDevice(
      label: 'android',
      deviceId: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
      server: server,
    );
    addTearDown(desktop.dispose);
    addTearDown(android.dispose);

    final item = await desktop.itemRepo.create(
      const CreateItemRequest(name: 'Shared', baseUnit: 'kg'),
    );
    await desktop.sync();
    await android.sync();

    await desktop.itemRepo.update(
      item.id,
      const UpdateItemRequest(name: 'DesktopEdit'),
    );
    await android.itemRepo.update(
      item.id,
      const UpdateItemRequest(name: 'AndroidEdit'),
    );

    await desktop.sync();

    // Isolate push-conflict handling from the subsequent pull apply.
    android.api.suppressPullChanges = true;
    final androidState = await android.sync();
    android.api.suppressPullChanges = false;

    expect((await android.items.getById(item.id))!.name, 'AndroidEdit');
    expect((await android.items.getById(item.id))!.syncVersion, 1);
    final jobs = await (android.db.select(android.db.syncQueue)
          ..where((t) => t.entityId.equals(item.id)))
        .get();
    expect(jobs, isNotEmpty);
    expect(jobs.any((j) => j.status == SyncQueueStatus.conflict.wire), isTrue);
    expect(androidState.lastResultMessage, contains('conflicts=1'));
    final conflictJob =
        jobs.firstWhere((j) => j.status == SyncQueueStatus.conflict.wire);
    expect(conflictJob.lastError, contains('VERSION_CONFLICT'));
    expect(conflictJob.lastError, contains('server_payload'));
    expect(conflictJob.lastError, contains('DesktopEdit'));
  });

  test('PART4 duplicate mutation replay completes without duplicating rows',
      () async {
    final device = await _openDevice(
      label: 'macos',
      deviceId: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
      server: server,
    );
    addTearDown(device.dispose);

    final created = await device.itemRepo.create(
      const CreateItemRequest(name: 'ReplayMe', baseUnit: 'piece'),
    );
    final job = (await device.queue.listPending()).single;
    await device.sync();
    expect(await device.queue.pendingCount(), 0);

    // Re-queue the same mutation_id (simulates duplicate delivery).
    await (device.db.update(device.db.syncQueue)
          ..where((t) => t.id.equals(job.id)))
        .write(
          const SyncQueueCompanion(
            status: Value('pending'),
            lastError: Value(null),
          ),
        );

    await device.sync();
    expect(await device.queue.pendingCount(), 0);
    final listed = await device.items.listActive('biz-1');
    expect(listed, hasLength(1));
    expect(listed.single.name, 'ReplayMe');
    expect(listed.single.id, created.id);
  });

  test('PART5 offline create all masters then reconnect drains queue',
      () async {
    final device = await _openDevice(
      label: 'macos',
      deviceId: '12121212-1212-1212-1212-121212121212',
      server: server,
    );
    addTearDown(device.dispose);

    // Mark bootstrapped so reconnect only pushes/pulls (steady state).
    await device.metadata.setPullCursor('c-0');
    await device.metadata.setBootstrappedAt(DateTime.utc(2026));
    await device.metadata.setLastServerSchemaVersion(1);

    await device.categoryRepo.createCategory(
      const CreateCategoryRequest(name: 'OfflineCat'),
    );
    await device.partyRepo.create(
      const CreatePartyRequest(name: 'OfflineParty', mobile: '9222222222'),
    );
    await device.itemRepo.create(
      const CreateItemRequest(name: 'OfflineItem', baseUnit: 'box'),
    );

    expect(await device.categories.listActive('biz-1'), hasLength(1));
    expect(await device.parties.listActive('biz-1'), hasLength(1));
    expect(await device.items.listActive('biz-1'), hasLength(1));
    expect(await device.queue.pendingCount(), 3);

    // Offline short-circuit leaves queue intact.
    var offlineState =
        const SyncState(connectivity: SyncConnectivityStatus.offline);
    await device.coordinator.orchestrate(
      currentState: offlineState,
      emit: (update) => offlineState = update(offlineState),
    );
    expect(offlineState.lifecycle, SyncLifecycleState.offline);
    expect(await device.queue.pendingCount(), 3);

    // Reconnect drains.
    final online = await device.sync();
    expect(await device.queue.pendingCount(), 0);
    expect(online.lastResultMessage, contains('push=3'));
    expect(online.lifecycle, SyncLifecycleState.idle);
  });

  test('PART6 cursor advances across pulls and soft-delete is in pull stream',
      () async {
    final desktop = await _openDevice(
      label: 'macos',
      deviceId: '34343434-3434-3434-3434-343434343434',
      server: server,
    );
    final android = await _openDevice(
      label: 'android',
      deviceId: '56565656-5656-5656-5656-565656565656',
      server: server,
    );
    addTearDown(desktop.dispose);
    addTearDown(android.dispose);

    final cat = await desktop.categoryRepo.createCategory(
      const CreateCategoryRequest(name: 'CursorCat'),
    );
    await desktop.sync();
    final cursorAfterCreate = desktop.metadata.pullCursor;
    expect(cursorAfterCreate, isNotNull);

    await android.sync();
    final androidCursor = android.metadata.pullCursor;
    expect(androidCursor, isNotNull);

    await desktop.categoryRepo.deleteCategory(cat.id);
    await desktop.sync();
    expect(desktop.metadata.pullCursor, isNot(cursorAfterCreate));

    await android.sync();
    expect((await android.categories.getById(cat.id))!.isDeleted, isTrue);
    expect(android.metadata.pullCursor, isNot(androidCursor));
  });
}
