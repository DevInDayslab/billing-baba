import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class BrandSync {
  BrandSync(this._db);

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
    final existing = await (_db.select(_db.brandsLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    if (isDeleted) {
      await _db.into(_db.brandsLocal).insertOnConflictUpdate(
            BrandsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              name: existing?.name ?? _str(payload, 'name') ?? '',
              syncVersion: Value(syncVersion),
              createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
              updatedAt: updatedAt.toUtc(),
              deletedAt: Value((deletedAt ?? updatedAt).toUtc()),
              isDeleted: const Value(true),
              deviceId: Value(deviceId),
              itemCount: Value(existing?.itemCount ?? 0),
            ),
          );
      return;
    }

    final name = _str(payload, 'name');
    await _db.into(_db.brandsLocal).insertOnConflictUpdate(
          BrandsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: (name != null && name.isNotEmpty)
                ? name
                : (existing?.name ?? ''),
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            isDeleted: const Value(false),
            deletedAt: const Value(null),
            deviceId: Value(deviceId),
            itemCount: Value(existing?.itemCount ?? 0),
          ),
        );
  }

  Future<void> updateAckMeta({
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(_db.brandsLocal)..where((t) => t.id.equals(entityId)))
        .write(
      BrandsLocalCompanion(
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
}
