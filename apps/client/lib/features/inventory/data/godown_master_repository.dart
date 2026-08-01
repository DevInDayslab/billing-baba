import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/godown_local_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/models/dto/godown_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:billing_baba/features/inventory/models/requests/godown_requests.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _godownsEntity = 'godowns';

/// Local-first godown writes + SyncQueue enqueue.
class GodownMasterRepository {
  GodownMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final GodownLocalSource _local;
  final SyncQueue _syncQueue;
  final InventoryRemoteDataSource _remote;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  GodownLocalSource get local => _local;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for godown operations');
    }
    return id;
  }

  Future<PaginatedGodownsDto> list(GodownListQuery query) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listActive(businessId, searchQuery: query.q);
    final start = (query.page - 1) * query.limit;
    final pageItems = start >= all.length
        ? <GodownDto>[]
        : all.skip(start).take(query.limit).toList();
    return PaginatedGodownsDto(
      godowns: pageItems,
      meta: PaginationMetaDto(
        page: query.page,
        limit: query.limit,
        total: all.length,
      ),
    );
  }

  Future<GodownDto?> getActive(String id) async {
    final local = await _local.getActiveDto(id);
    if (local != null) return local;
    try {
      final remote = await _remote.getGodown(id);
      final businessId = _requireBusinessId();
      await _local.upsertFromDto(businessId, remote);
      return remote;
    } on Object {
      return null;
    }
  }

  Future<GodownDto> create(CreateGodownRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final name = request.name.trim();
    final address = request.address?.trim().isEmpty == true
        ? null
        : request.address?.trim();
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      address: address,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _godownsEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: {'name': name, 'address': address, 'is_default': false},
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDto(id))!;
  }

  Future<GodownDto> update(String id, UpdateGodownRequest request) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) {
      throw StateError('Godown not found locally');
    }
    final now = DateTime.now().toUtc();
    final name = (request.name ?? existing.name).trim();
    final address = request.address ?? existing.address;
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      address: address,
      isDefault: existing.isDefault,
      syncVersion: existing.syncVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call() ?? existing.deviceId,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _godownsEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: {
        'name': name,
        'address': address,
        'is_default': existing.isDefault,
      },
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDto(id))!;
  }

  Future<void> softDelete(String id) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) return;
    final now = DateTime.now().toUtc();
    await _local.softDelete(id: id, deletedAt: now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _godownsEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }

  Future<void> _hydrateIfEmpty(String businessId) async {
    // Offline developer session — ensure a local default warehouse, no API.
    if (businessId == 'dev-business' || businessId == 'local-business') {
      await _ensureDefaultLocalGodown(businessId);
      return;
    }

    final count = await _local.countActive(businessId);
    if (count > 0) return;
    try {
      var page = 1;
      while (true) {
        final response = await _remote.listGodowns(
          GodownListQuery(page: page, limit: 100),
        );
        for (final g in response.godowns) {
          await _local.upsertFromDto(businessId, g);
        }
        if (response.godowns.length < 100) break;
        if (page * 100 >= response.meta.total) break;
        page += 1;
      }
    } on Object {
      // Offline / empty.
    }

    // Still empty after hydrate (API unreachable) — keep Adjust Stock usable.
    if (await _local.countActive(businessId) == 0) {
      await _ensureDefaultLocalGodown(businessId);
    }
  }

  Future<void> _ensureDefaultLocalGodown(String businessId) async {
    if (await _local.countActive(businessId) > 0) return;
    final now = DateTime.now().toUtc().toIso8601String();
    await _local.upsertFromDto(
      businessId,
      GodownDto(
        id: 'local-default-godown',
        name: 'Main Warehouse',
        isDefault: true,
        stockItemCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
