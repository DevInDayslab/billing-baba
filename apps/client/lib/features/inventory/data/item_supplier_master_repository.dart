import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_supplier_local_source.dart';
import 'package:billing_baba/features/inventory/models/dto/item_supplier_dto.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _itemSuppliersEntity = 'item_suppliers';

class ItemSupplierMasterRepository {
  ItemSupplierMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._storage,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final ItemSupplierLocalSource _local;
  final SyncQueue _syncQueue;
  final InventoryRemoteDataSource _remote;
  final StorageService _storage;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for item supplier operations');
    }
    return id;
  }

  Future<List<ItemSupplierDto>> listForItem(String itemId) async {
    final businessId = _requireBusinessId();
    await migrateFromLegacyStorageIfNeeded();
    await _hydrateItemIfEmpty(businessId, itemId);
    return _local.listActiveForItem(businessId, itemId);
  }

  Future<Map<String, List<String>>> groupedPartyIds() async {
    final businessId = _requireBusinessId();
    await migrateFromLegacyStorageIfNeeded();
    return _local.groupedPartyIds(businessId);
  }

  Future<void> replaceForItem(
    String itemId,
    List<String> partyIds, {
    String? defaultPartyId,
  }) async {
    final businessId = _requireBusinessId();
    await migrateFromLegacyStorageIfNeeded();
    final cleaned = partyIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
    final uniquePartyIds = <String>[];
    for (final partyId in cleaned) {
      if (!uniquePartyIds.contains(partyId)) {
        uniquePartyIds.add(partyId);
      }
    }

    final resolvedDefault = uniquePartyIds.isEmpty
        ? null
        : (defaultPartyId != null && uniquePartyIds.contains(defaultPartyId)
              ? defaultPartyId
              : uniquePartyIds.first);

    final existing = await _local.listActiveRowsForItem(businessId, itemId);
    final existingByPartyId = {
      for (final row in existing) row.partyId: row,
    };
    final now = DateTime.now().toUtc();

    for (final row in existing) {
      if (uniquePartyIds.contains(row.partyId)) continue;
      await _local.softDelete(id: row.id, deletedAt: now);
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemSuppliersEntity,
        entityId: row.id,
        operation: SyncQueueOperation.delete,
        payload: const {},
        baseSyncVersion: row.syncVersion,
        clientUpdatedAt: now,
      );
    }

    for (var index = 0; index < uniquePartyIds.length; index++) {
      final partyId = uniquePartyIds[index];
      final existingRow = existingByPartyId[partyId];
      final isDefault = partyId == resolvedDefault;
      if (existingRow != null) {
        final needsUpdate =
            existingRow.sortOrder != index ||
            existingRow.isDefault != isDefault;
        if (!needsUpdate) continue;
        await _local.upsertRow(
          id: existingRow.id,
          businessId: businessId,
          itemId: itemId,
          partyId: partyId,
          isDefault: isDefault,
          sortOrder: index,
          syncVersion: existingRow.syncVersion,
          createdAt: existingRow.createdAt,
          updatedAt: now,
          deviceId: _deviceIdReader?.call() ?? existingRow.deviceId,
        );
        await _syncQueue.enqueueRowMutation(
          businessId: businessId,
          deviceId: _deviceIdReader?.call(),
          entityType: _itemSuppliersEntity,
          entityId: existingRow.id,
          operation: SyncQueueOperation.update,
          payload: {
            'item_id': itemId,
            'party_id': partyId,
            'is_default': isDefault,
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
        partyId: partyId,
        isDefault: isDefault,
        sortOrder: index,
        syncVersion: 0,
        createdAt: now,
        updatedAt: now,
        deviceId: _deviceIdReader?.call(),
      );
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemSuppliersEntity,
        entityId: id,
        operation: SyncQueueOperation.create,
        payload: {
          'item_id': itemId,
          'party_id': partyId,
          'is_default': isDefault,
          'sort_order': index,
        },
        clientUpdatedAt: now,
      );
    }
  }

  Future<void> removeAllForItem(String itemId) async {
    await replaceForItem(itemId, const []);
  }

  Future<void> migrateFromLegacyStorageIfNeeded() async {
    final businessId = _requireBusinessId();
    final migratedKey = StorageKeys.itemSuppliersMigratedFor(businessId);
    if (_storage.read(migratedKey) == 'true') return;

    if (await _local.countActive(businessId) > 0) {
      await _storage.write(migratedKey, 'true');
      return;
    }

    final raw = _storage.read('${StorageKeys.localItemSuppliers}_$businessId');
    if (raw == null || raw.isEmpty) {
      await _storage.write(migratedKey, 'true');
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final now = DateTime.now().toUtc();
        for (final entry in decoded.entries) {
          final itemId = entry.key;
          final value = entry.value;
          if (itemId is! String || value is! List) continue;
          final partyIds = value.whereType<String>().toList();
          for (var index = 0; index < partyIds.length; index++) {
            final partyId = partyIds[index].trim();
            if (partyId.isEmpty) continue;
            final id = _uuid.v4();
            await _local.upsertRow(
              id: id,
              businessId: businessId,
              itemId: itemId,
              partyId: partyId,
              isDefault: index == 0,
              sortOrder: index,
              syncVersion: 0,
              createdAt: now,
              updatedAt: now,
              deviceId: _deviceIdReader?.call(),
            );
            await _syncQueue.enqueueRowMutation(
              businessId: businessId,
              deviceId: _deviceIdReader?.call(),
              entityType: _itemSuppliersEntity,
              entityId: id,
              operation: SyncQueueOperation.create,
              payload: {
                'item_id': itemId,
                'party_id': partyId,
                'is_default': index == 0,
                'sort_order': index,
              },
              clientUpdatedAt: now,
            );
          }
        }
      }
    } on Object {
      // Ignore corrupt legacy cache.
    }

    await _storage.write(migratedKey, 'true');
    await _storage.remove('${StorageKeys.localItemSuppliers}_$businessId');
  }

  Future<void> _hydrateItemIfEmpty(String businessId, String itemId) async {
    if (await _local.countActiveForItem(businessId, itemId) > 0) return;
    try {
      final remote = await _remote.listItemSuppliers(itemId);
      for (final dto in remote) {
        await _local.upsertFromDto(businessId, dto);
      }
    } on Object {
      // Offline — leave empty.
    }
  }
}
