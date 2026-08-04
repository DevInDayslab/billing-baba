import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/brand_local_source.dart';
import 'package:billing_baba/features/inventory/data/category_local_source.dart';
import 'package:billing_baba/features/inventory/data/inventory_stock_local_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_alternative_local_source.dart';
import 'package:billing_baba/features/inventory/data/item_alternatives_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_local_source.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _itemAlternativesEntity = 'item_alternatives';

class ItemAlternativeMasterRepository {
  ItemAlternativeMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._items,
    required this._brands,
    required this._categories,
    required this._stockLocal,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final ItemAlternativeLocalSource _local;
  final SyncQueue _syncQueue;
  final ItemAlternativesRemoteDataSource _remote;
  final ItemLocalSource _items;
  final BrandLocalSource _brands;
  final CategoryLocalSource _categories;
  final InventoryStockLocalDataSource _stockLocal;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for item alternative operations');
    }
    return id;
  }

  Future<List<ItemAlternativeDto>> listForItem(String itemId) async {
    final businessId = _requireBusinessId();
    await _hydrateItemIfEmpty(businessId, itemId);
    final rows = await _local.listActiveRowsForItem(businessId, itemId);
    return _toDtos(businessId, rows);
  }

  Future<Map<String, List<String>>> groupedAlternativeItemIds() async {
    final businessId = _requireBusinessId();
    return _local.groupedAlternativeItemIds(businessId);
  }

  Future<List<ItemAlternativeDto>> addAlternative(
    String itemId,
    String alternativeItemId,
  ) async {
    final businessId = _requireBusinessId();
    await _hydrateItemIfEmpty(businessId, itemId);

    if (itemId == alternativeItemId) {
      throw StateError('Item cannot be an alternative to itself');
    }

    final existing = await _local.findActivePair(
      businessId: businessId,
      itemId: itemId,
      alternativeItemId: alternativeItemId,
    );
    if (existing != null) {
      return listForItem(itemId);
    }

    final activeRows = await _local.listActiveRowsForItem(businessId, itemId);
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final sortOrder = activeRows.length;

    await _local.upsertRow(
      id: id,
      businessId: businessId,
      itemId: itemId,
      alternativeItemId: alternativeItemId,
      sortOrder: sortOrder,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _itemAlternativesEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: {
        'item_id': itemId,
        'alternative_item_id': alternativeItemId,
        'sort_order': sortOrder,
      },
      clientUpdatedAt: now,
    );

    return listForItem(itemId);
  }

  Future<void> removeAlternative(
    String itemId,
    String alternativeItemId,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.findActivePair(
      businessId: businessId,
      itemId: itemId,
      alternativeItemId: alternativeItemId,
    );
    if (existing == null) return;

    final now = DateTime.now().toUtc();
    await _local.softDelete(id: existing.id, deletedAt: now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _itemAlternativesEntity,
      entityId: existing.id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }

  Future<void> reorderAlternatives(
    String itemId,
    List<String> orderedAlternativeItemIds,
  ) async {
    final businessId = _requireBusinessId();
    final existing = await _local.listActiveRowsForItem(businessId, itemId);
    final byAltId = {
      for (final row in existing) row.alternativeItemId: row,
    };
    final now = DateTime.now().toUtc();

    for (var index = 0; index < orderedAlternativeItemIds.length; index++) {
      final altId = orderedAlternativeItemIds[index];
      final row = byAltId[altId];
      if (row == null || row.sortOrder == index) continue;

      await _local.upsertRow(
        id: row.id,
        businessId: businessId,
        itemId: itemId,
        alternativeItemId: altId,
        sortOrder: index,
        syncVersion: row.syncVersion,
        createdAt: row.createdAt,
        updatedAt: now,
        deviceId: _deviceIdReader?.call() ?? row.deviceId,
      );
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemAlternativesEntity,
        entityId: row.id,
        operation: SyncQueueOperation.update,
        payload: {
          'item_id': itemId,
          'alternative_item_id': altId,
          'sort_order': index,
        },
        baseSyncVersion: row.syncVersion,
        clientUpdatedAt: now,
      );
    }
  }

  Future<void> replaceForItem(
    String itemId,
    List<String> alternativeItemIds,
  ) async {
    final businessId = _requireBusinessId();
    final cleaned = <String>[];
    for (final id in alternativeItemIds) {
      final trimmed = id.trim();
      if (trimmed.isEmpty || trimmed == itemId) continue;
      if (!cleaned.contains(trimmed)) cleaned.add(trimmed);
    }

    final existing = await _local.listActiveRowsForItem(businessId, itemId);
    final existingByAltId = {
      for (final row in existing) row.alternativeItemId: row,
    };
    final now = DateTime.now().toUtc();

    for (final row in existing) {
      if (cleaned.contains(row.alternativeItemId)) continue;
      await _local.softDelete(id: row.id, deletedAt: now);
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemAlternativesEntity,
        entityId: row.id,
        operation: SyncQueueOperation.delete,
        payload: const {},
        baseSyncVersion: row.syncVersion,
        clientUpdatedAt: now,
      );
    }

    for (var index = 0; index < cleaned.length; index++) {
      final altId = cleaned[index];
      final existingRow = existingByAltId[altId];
      if (existingRow != null) {
        if (existingRow.sortOrder == index) continue;
        await _local.upsertRow(
          id: existingRow.id,
          businessId: businessId,
          itemId: itemId,
          alternativeItemId: altId,
          sortOrder: index,
          syncVersion: existingRow.syncVersion,
          createdAt: existingRow.createdAt,
          updatedAt: now,
          deviceId: _deviceIdReader?.call() ?? existingRow.deviceId,
        );
        await _syncQueue.enqueueRowMutation(
          businessId: businessId,
          deviceId: _deviceIdReader?.call(),
          entityType: _itemAlternativesEntity,
          entityId: existingRow.id,
          operation: SyncQueueOperation.update,
          payload: {
            'item_id': itemId,
            'alternative_item_id': altId,
            'sort_order': index,
          },
          baseSyncVersion: existingRow.syncVersion,
          clientUpdatedAt: now,
        );
        continue;
      }

      final id = _uuid.v4();
      await _local.upsertRow(
        id: id,
        businessId: businessId,
        itemId: itemId,
        alternativeItemId: altId,
        sortOrder: index,
        syncVersion: 0,
        createdAt: now,
        updatedAt: now,
        deviceId: _deviceIdReader?.call(),
      );
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemAlternativesEntity,
        entityId: id,
        operation: SyncQueueOperation.create,
        payload: {
          'item_id': itemId,
          'alternative_item_id': altId,
          'sort_order': index,
        },
        clientUpdatedAt: now,
      );
    }
  }

  /// Soft-deletes every alternative owned by [itemId] and enqueues DELETE sync jobs.
  Future<void> removeAllForItem(String itemId) async {
    final businessId = _requireBusinessId();
    final existing = await _local.listActiveRowsForItem(businessId, itemId);
    if (existing.isEmpty) return;

    final now = DateTime.now().toUtc();
    for (final row in existing) {
      await _local.softDelete(id: row.id, deletedAt: now);
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemAlternativesEntity,
        entityId: row.id,
        operation: SyncQueueOperation.delete,
        payload: const {},
        baseSyncVersion: row.syncVersion,
        clientUpdatedAt: now,
      );
    }
  }

  /// Soft-deletes rows where [itemId] is referenced as an alternative on other items.
  Future<void> removeAllReferencingItem(String itemId) async {
    final businessId = _requireBusinessId();
    final existing = await _local.listActiveRowsReferencingItem(
      businessId,
      itemId,
    );
    if (existing.isEmpty) return;

    final now = DateTime.now().toUtc();
    for (final row in existing) {
      await _local.softDelete(id: row.id, deletedAt: now);
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemAlternativesEntity,
        entityId: row.id,
        operation: SyncQueueOperation.delete,
        payload: const {},
        baseSyncVersion: row.syncVersion,
        clientUpdatedAt: now,
      );
    }
  }

  Future<void> _hydrateItemIfEmpty(String businessId, String itemId) async {
    if (await _local.countActiveForItem(businessId, itemId) > 0) return;
    try {
      final remote = await _remote.listAlternatives(itemId);
      for (final dto in remote) {
        await _local.upsertFromRemoteRow(
          businessId: businessId,
          id: dto.id,
          itemId: dto.itemId,
          alternativeItemId: dto.alternativeItemId,
          sortOrder: dto.sortOrder,
        );
      }
    } on Object {
      // Offline — leave empty.
    }
  }

  Future<List<ItemAlternativeDto>> _toDtos(
    String businessId,
    List<ItemAlternativeTableData> rows,
  ) async {
    final brandRows = await _brands.listActive(businessId);
    final brandById = {for (final b in brandRows) b.id: b.name};
    final categoryRows = await _categories.listActive(businessId);
    final categoryById = {for (final c in categoryRows) c.id: c.name};

    final dtos = <ItemAlternativeDto>[];
    for (final row in rows) {
      final altItem = await _items.getById(row.alternativeItemId);
      if (altItem == null || altItem.isDeleted) continue;

      final stockQty = await _stockLocal.totalQuantityForItem(
        businessId: businessId,
        itemId: row.alternativeItemId,
      );

      dtos.add(
        ItemAlternativeDto(
          id: row.id,
          itemId: row.itemId,
          alternativeItemId: row.alternativeItemId,
          sortOrder: row.sortOrder,
          alternativeItem: AlternativeItemDto(
            id: altItem.id,
            name: altItem.name,
            barcode: altItem.barcode,
            brandName: altItem.brandId != null
                ? brandById[altItem.brandId]
                : null,
            categoryName: altItem.categoryId != null
                ? categoryById[altItem.categoryId]
                : null,
            salePrice: double.tryParse(altItem.salePrice) ?? 0,
            stockQuantity: stockQty,
          ),
        ),
      );
    }
    return dtos;
  }
}
