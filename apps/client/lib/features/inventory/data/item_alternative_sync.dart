import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class ItemAlternativeSync {
  ItemAlternativeSync(this._db);

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
      _db.itemAlternativesLocal,
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
          .into(_db.itemAlternativesLocal)
          .insertOnConflictUpdate(
            ItemAlternativesLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              itemId: existing?.itemId ?? _str(payload, 'item_id') ?? '',
              alternativeItemId:
                  existing?.alternativeItemId ??
                  _str(payload, 'alternative_item_id') ??
                  '',
              sortOrder: Value(existing?.sortOrder ?? 0),
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
    final alternativeItemId = _str(payload, 'alternative_item_id');
    await _db
        .into(_db.itemAlternativesLocal)
        .insertOnConflictUpdate(
          ItemAlternativesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            itemId: (itemId != null && itemId.isNotEmpty)
                ? itemId
                : (existing?.itemId ?? ''),
            alternativeItemId:
                (alternativeItemId != null && alternativeItemId.isNotEmpty)
                ? alternativeItemId
                : (existing?.alternativeItemId ?? ''),
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
      _db.itemAlternativesLocal,
    )..where((t) => t.id.equals(entityId))).write(
      ItemAlternativesLocalCompanion(
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
}
