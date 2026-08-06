import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class ItemTierPriceSync {
  ItemTierPriceSync(this._db);

  final AppDatabase _db;

  Future<void> applyChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(
      _db.itemTierPricesLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    if (isDeleted) {
      await _db
          .into(_db.itemTierPricesLocal)
          .insertOnConflictUpdate(
            ItemTierPricesLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              itemId: existing?.itemId ?? _str(payload, 'item_id') ?? '',
              pricingTier:
                  existing?.pricingTier ?? _str(payload, 'pricing_tier') ?? '',
              price: existing?.price ?? _double(payload, 'price') ?? 0,
              syncVersion: Value(syncVersion),
              createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
              updatedAt: updatedAt.toUtc(),
              deletedAt: Value((deletedAt ?? updatedAt).toUtc()),
              isDeleted: const Value(true),
              deviceId: Value(deviceId),
            ),
          );
      return;
    }

    final itemId = _str(payload, 'item_id');
    final pricingTier = _str(payload, 'pricing_tier');
    await _db
        .into(_db.itemTierPricesLocal)
        .insertOnConflictUpdate(
          ItemTierPricesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            itemId: (itemId != null && itemId.isNotEmpty)
                ? itemId
                : (existing?.itemId ?? ''),
            pricingTier: (pricingTier != null && pricingTier.isNotEmpty)
                ? pricingTier
                : (existing?.pricingTier ?? ''),
            price: _double(payload, 'price') ?? existing?.price ?? 0,
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            isDeleted: const Value(false),
            deletedAt: const Value(null),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> updateAckMeta({
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(
      _db.itemTierPricesLocal,
    )..where((t) => t.id.equals(entityId))).write(
      ItemTierPricesLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }

  static String? _str(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value == null) return null;
    return value.toString();
  }

  static double? _double(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
