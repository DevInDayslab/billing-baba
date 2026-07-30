import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/unit_local_source.dart';
import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/unit_dto.dart';
import 'package:billing_baba/features/inventory/models/requests/unit_requests.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _unitsEntity = 'unit_definitions';

/// Local-first unit definition writes + SyncQueue enqueue.
class UnitMasterRepository {
  UnitMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final UnitLocalSource _local;
  final SyncQueue _syncQueue;
  final InventoryRemoteDataSource _remote;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  UnitLocalSource get local => _local;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for unit operations');
    }
    return id;
  }

  Future<PaginatedUnitsDto> list(UnitListQuery query) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listActive(
      businessId,
      searchQuery: query.q,
      isActive: query.isActive,
    );
    final start = (query.page - 1) * query.limit;
    final pageItems = start >= all.length
        ? <UnitListDto>[]
        : all.skip(start).take(query.limit).toList();
    return PaginatedUnitsDto(
      units: pageItems,
      meta: PaginationMetaDto(
        page: query.page,
        limit: query.limit,
        total: all.length,
      ),
    );
  }

  Future<UnitDetailDto?> getActive(String id) async {
    final local = await _local.getActiveDetail(id);
    if (local != null) return local;
    try {
      final remote = await _remote.getUnit(id);
      final businessId = _requireBusinessId();
      await _local.upsertFromDetailDto(businessId, remote);
      return remote;
    } on Object {
      return null;
    }
  }

  Future<UnitDetailDto> create(CreateUnitRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final name = request.name.trim();
    final shortName = request.shortName.trim();
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      shortName: shortName,
      symbol: request.symbol?.trim().isEmpty == true ? null : request.symbol,
      decimalPlaces: request.decimalPlaces,
      isSystem: request.isSystem,
      isActive: request.isActive,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _unitsEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: _domainPayload(
        name: name,
        shortName: shortName,
        symbol: request.symbol,
        decimalPlaces: request.decimalPlaces,
        isSystem: request.isSystem,
        isActive: request.isActive,
      ),
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDetail(id))!;
  }

  Future<UnitDetailDto> update(String id, UpdateUnitRequest request) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) {
      throw StateError('Unit not found locally');
    }
    final now = DateTime.now().toUtc();
    final name = (request.name ?? existing.name).trim();
    final shortName = (request.shortName ?? existing.shortName).trim();
    final symbol = request.symbol ?? existing.symbol;
    final decimalPlaces = request.decimalPlaces ?? existing.decimalPlaces;
    final isActive = request.isActive ?? existing.isActive;
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      shortName: shortName,
      symbol: symbol,
      decimalPlaces: decimalPlaces,
      isSystem: existing.isSystem,
      isActive: isActive,
      syncVersion: existing.syncVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call() ?? existing.deviceId,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _unitsEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: _domainPayload(
        name: name,
        shortName: shortName,
        symbol: symbol,
        decimalPlaces: decimalPlaces,
        isSystem: existing.isSystem,
        isActive: isActive,
      ),
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDetail(id))!;
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
      entityType: _unitsEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }

  Future<void> _hydrateIfEmpty(String businessId) async {
    final count = await _local.countActive(businessId);
    if (count > 0) return;
    try {
      var page = 1;
      while (true) {
        final response = await _remote.listUnits(
          UnitListQuery(page: page, limit: 100),
        );
        for (final u in response.units) {
          await _local.upsertFromDetailDto(
            businessId,
            UnitDetailDto(
              id: u.id,
              name: u.name,
              shortName: u.shortName,
              decimalPlaces: u.decimalPlaces,
              isSystem: u.isSystem,
              isActive: u.isActive,
              createdAt: u.createdAt,
              updatedAt: u.updatedAt,
              symbol: u.symbol,
            ),
          );
        }
        if (response.units.length < 100) break;
        if (page * 100 >= response.meta.total) break;
        page += 1;
      }
    } on Object {
      // Offline / empty — leave empty.
    }
  }

  static Map<String, dynamic> _domainPayload({
    required String name,
    required String shortName,
    required int decimalPlaces, required bool isSystem, required bool isActive, String? symbol,
  }) {
    return {
      'name': name,
      'short_name': shortName,
      'symbol': symbol,
      'decimal_places': decimalPlaces,
      'is_system': isSystem,
      'is_active': isActive,
    };
  }
}
