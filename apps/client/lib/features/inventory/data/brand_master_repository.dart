import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/brand_local_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/models/dto/brand_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:billing_baba/features/inventory/models/requests/brand_requests.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _brandsEntity = 'brands';

class BrandMasterRepository {
  BrandMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final BrandLocalSource _local;
  final SyncQueue _syncQueue;
  final InventoryRemoteDataSource _remote;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for brand operations');
    }
    return id;
  }

  Future<PaginatedBrandsDto> list(BrandListQuery query) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final all = await _local.listActive(businessId, searchQuery: query.q);
    final start = (query.page - 1) * query.limit;
    final pageItems = start >= all.length
        ? <BrandDto>[]
        : all.skip(start).take(query.limit).toList();
    return PaginatedBrandsDto(
      brands: pageItems,
      meta: PaginationMetaDto(
        page: query.page,
        limit: query.limit,
        total: all.length,
      ),
    );
  }

  Future<BrandDto?> getActive(String id) async {
    final local = await _local.getActiveDto(id);
    if (local != null) return local;
    try {
      final remote = await _remote.getBrand(id);
      final businessId = _requireBusinessId();
      await _local.upsertFromDto(businessId, remote);
      return remote;
    } on Object {
      return null;
    }
  }

  Future<BrandDto> create(CreateBrandRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final name = request.name.trim();
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _brandsEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: {'name': name},
      clientUpdatedAt: now,
    );
    return BrandDto(
      id: id,
      name: name,
      itemCount: 0,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
  }

  Future<BrandDto> update(String id, UpdateBrandRequest request) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) {
      throw StateError('Brand not found locally');
    }
    final now = DateTime.now().toUtc();
    final name = request.name?.trim() ?? existing.name;
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      name: name,
      itemCount: existing.itemCount,
      syncVersion: existing.syncVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call() ?? existing.deviceId,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _brandsEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: {'name': name},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
    return BrandDto(
      id: id,
      name: name,
      itemCount: existing.itemCount,
      createdAt: existing.createdAt.toUtc().toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
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
      entityType: _brandsEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }

  Future<void> _hydrateIfEmpty(String businessId) async {
    if (await _local.countActive(businessId) > 0) return;
    try {
      var page = 1;
      while (true) {
        final response = await _remote.listBrands(
          BrandListQuery(page: page, limit: 100),
        );
        for (final dto in response.brands) {
          await _local.upsertFromDto(businessId, dto);
        }
        if (response.brands.length < 100) break;
        if (page * 100 >= response.meta.total) break;
        page += 1;
      }
    } on Object {
      // Offline — leave empty.
    }
  }
}
