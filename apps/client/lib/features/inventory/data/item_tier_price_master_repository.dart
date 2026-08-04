import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_tier_price_local_source.dart';
import 'package:billing_baba/features/inventory/models/dto/item_tier_price_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/item_summary_dto.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _itemTierPricesEntity = 'item_tier_prices';

class ItemTierPriceMasterRepository {
  ItemTierPriceMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._storage,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final ItemTierPriceLocalSource _local;
  final SyncQueue _syncQueue;
  final InventoryRemoteDataSource _remote;
  final StorageService _storage;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for item tier price operations');
    }
    return id;
  }

  Future<List<ItemTierPriceDto>> listForItem(String itemId) async {
    final businessId = _requireBusinessId();
    await migrateFromLegacyStorageIfNeeded();
    await _hydrateItemIfEmpty(businessId, itemId);
    return _local.listActiveForItem(businessId, itemId);
  }

  Future<Map<String, Map<String, double>>> groupedByItemId() async {
    final businessId = _requireBusinessId();
    await migrateFromLegacyStorageIfNeeded();
    return _local.groupedByItemId(businessId);
  }

  Future<void> replaceForItem(
    String itemId,
    Map<String, double> tierPrices,
  ) async {
    final businessId = _requireBusinessId();
    await migrateFromLegacyStorageIfNeeded();

    final cleaned = <String, double>{};
    for (final entry in tierPrices.entries) {
      if (entry.value <= 0) continue;
      cleaned[entry.key] = entry.value;
    }

    final existing = await _local.listActiveRowsForItem(businessId, itemId);
    final existingByTierKey = {
      for (final row in existing)
        PriceTier.fromApiTier(row.pricingTier): row,
    };
    final now = DateTime.now().toUtc();

    for (final row in existing) {
      final tierKey = PriceTier.fromApiTier(row.pricingTier);
      if (cleaned.containsKey(tierKey)) continue;
      await _local.softDelete(id: row.id, deletedAt: now);
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemTierPricesEntity,
        entityId: row.id,
        operation: SyncQueueOperation.delete,
        payload: const {},
        baseSyncVersion: row.syncVersion,
        clientUpdatedAt: now,
      );
    }

    for (final entry in cleaned.entries) {
      final apiTier = PriceTier.toApiTier(entry.key);
      final price = entry.value;
      final existingRow = existingByTierKey[entry.key];
      if (existingRow != null) {
        if (existingRow.price == price) continue;
        await _local.upsertRow(
          id: existingRow.id,
          businessId: businessId,
          itemId: itemId,
          pricingTier: apiTier,
          price: price,
          syncVersion: existingRow.syncVersion,
          createdAt: existingRow.createdAt,
          updatedAt: now,
          deviceId: _deviceIdReader?.call() ?? existingRow.deviceId,
        );
        await _syncQueue.enqueueRowMutation(
          businessId: businessId,
          deviceId: _deviceIdReader?.call(),
          entityType: _itemTierPricesEntity,
          entityId: existingRow.id,
          operation: SyncQueueOperation.update,
          payload: {
            'item_id': itemId,
            'pricing_tier': apiTier,
            'price': _formatMoney(price),
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
        pricingTier: apiTier,
        price: price,
        syncVersion: 0,
        createdAt: now,
        updatedAt: now,
        deviceId: _deviceIdReader?.call(),
      );
      await _syncQueue.enqueueRowMutation(
        businessId: businessId,
        deviceId: _deviceIdReader?.call(),
        entityType: _itemTierPricesEntity,
        entityId: id,
        operation: SyncQueueOperation.create,
        payload: {
          'item_id': itemId,
          'pricing_tier': apiTier,
          'price': _formatMoney(price),
        },
        clientUpdatedAt: now,
      );
    }
  }

  Future<void> removeAllForItem(String itemId) async {
    await replaceForItem(itemId, const {});
  }

  Future<void> migrateFromLegacyStorageIfNeeded() async {
    final businessId = _requireBusinessId();
    final migratedKey = StorageKeys.itemTierPricesMigratedFor(businessId);
    if (_storage.read(migratedKey) == 'true') return;

    if (await _local.countActive(businessId) > 0) {
      await _storage.write(migratedKey, 'true');
      return;
    }

    final raw =
        _storage.read('${StorageKeys.localItemTierPrices}_$businessId');
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
          if (itemId is! String || value is! Map) continue;
          for (final tierEntry in value.entries) {
            final tierKey = tierEntry.key;
            final price = tierEntry.value;
            if (tierKey is! String || price is! num || price <= 0) continue;
            final id = _uuid.v4();
            final apiTier = PriceTier.toApiTier(tierKey);
            await _local.upsertRow(
              id: id,
              businessId: businessId,
              itemId: itemId,
              pricingTier: apiTier,
              price: price.toDouble(),
              syncVersion: 0,
              createdAt: now,
              updatedAt: now,
              deviceId: _deviceIdReader?.call(),
            );
            await _syncQueue.enqueueRowMutation(
              businessId: businessId,
              deviceId: _deviceIdReader?.call(),
              entityType: _itemTierPricesEntity,
              entityId: id,
              operation: SyncQueueOperation.create,
              payload: {
                'item_id': itemId,
                'pricing_tier': apiTier,
                'price': _formatMoney(price.toDouble()),
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
    await _storage.remove('${StorageKeys.localItemTierPrices}_$businessId');
  }

  Future<void> _hydrateItemIfEmpty(String businessId, String itemId) async {
    if (await _local.countActiveForItem(businessId, itemId) > 0) return;
    try {
      final remote = await _remote.getItemTierPrices(itemId);
      await _upsertRemoteTierPrices(businessId, itemId, remote);
    } on Object {
      // Offline — leave empty.
    }
  }

  Future<void> _upsertRemoteTierPrices(
    String businessId,
    String itemId,
    List<TierPriceDto> remote,
  ) async {
    if (remote.isEmpty) return;
    final now = DateTime.now().toUtc();
    for (final tier in remote) {
      final price = double.tryParse(tier.price) ?? 0;
      if (price <= 0) continue;
      final existing = await _findRowByItemAndTier(
        businessId,
        itemId,
        tier.pricingTier,
      );
      if (existing != null) {
        await _local.upsertRow(
          id: existing.id,
          businessId: businessId,
          itemId: itemId,
          pricingTier: tier.pricingTier,
          price: price,
          syncVersion: existing.syncVersion,
          createdAt: existing.createdAt,
          updatedAt: now,
        );
        continue;
      }
      await _local.upsertRow(
        id: _uuid.v4(),
        businessId: businessId,
        itemId: itemId,
        pricingTier: tier.pricingTier,
        price: price,
        syncVersion: 0,
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  Future<ItemTierPriceTableData?> _findRowByItemAndTier(
    String businessId,
    String itemId,
    String pricingTier,
  ) async {
    final rows = await _local.listActiveRowsForItem(businessId, itemId);
    for (final row in rows) {
      if (row.pricingTier == pricingTier) return row;
    }
    return null;
  }

  static String _formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}
