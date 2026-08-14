import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class ItemBomMaterialSync {
  ItemBomMaterialSync(this._db);

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
      _db.itemBomMaterialsLocal,
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
          .into(_db.itemBomMaterialsLocal)
          .insertOnConflictUpdate(
            ItemBomMaterialsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              itemId: existing?.itemId ?? _str(payload, 'item_id') ?? '',
              rawItemId:
                  existing?.rawItemId ?? _str(payload, 'raw_item_id') ?? '',
              qty: existing?.qty ?? _double(payload, 'qty') ?? 0,
              unitId: existing?.unitId ?? _str(payload, 'unit_id') ?? '',
              purchasePrice: Value(
                existing?.purchasePrice ??
                    _double(payload, 'purchase_price') ??
                    0,
              ),
              sortOrder: Value(existing?.sortOrder ?? _int(payload, 'sort_order') ?? 0),
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

    await _db
        .into(_db.itemBomMaterialsLocal)
        .insertOnConflictUpdate(
          ItemBomMaterialsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            itemId: _str(payload, 'item_id') ?? existing?.itemId ?? '',
            rawItemId: _str(payload, 'raw_item_id') ?? existing?.rawItemId ?? '',
            qty: _double(payload, 'qty') ?? existing?.qty ?? 0,
            unitId: _str(payload, 'unit_id') ?? existing?.unitId ?? '',
            purchasePrice: Value(
              _double(payload, 'purchase_price') ?? existing?.purchasePrice ?? 0,
            ),
            sortOrder: Value(
              _int(payload, 'sort_order') ?? existing?.sortOrder ?? 0,
            ),
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
      _db.itemBomMaterialsLocal,
    )..where((t) => t.id.equals(entityId))).write(
      ItemBomMaterialsLocalCompanion(
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

  static int? _int(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _double(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class ItemBomCostSync {
  ItemBomCostSync(this._db);

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
      _db.itemBomCostsLocal,
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
          .into(_db.itemBomCostsLocal)
          .insertOnConflictUpdate(
            ItemBomCostsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              itemId: existing?.itemId ?? _str(payload, 'item_id') ?? '',
              description:
                  existing?.description ?? _str(payload, 'description') ?? '',
              amount: Value(
                existing?.amount ?? _double(payload, 'amount') ?? 0,
              ),
              sortOrder: Value(existing?.sortOrder ?? _int(payload, 'sort_order') ?? 0),
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

    await _db
        .into(_db.itemBomCostsLocal)
        .insertOnConflictUpdate(
          ItemBomCostsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            itemId: _str(payload, 'item_id') ?? existing?.itemId ?? '',
            description:
                _str(payload, 'description') ?? existing?.description ?? '',
            amount: Value(_double(payload, 'amount') ?? existing?.amount ?? 0),
            sortOrder: Value(
              _int(payload, 'sort_order') ?? existing?.sortOrder ?? 0,
            ),
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
      _db.itemBomCostsLocal,
    )..where((t) => t.id.equals(entityId))).write(
      ItemBomCostsLocalCompanion(
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

  static int? _int(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _double(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
