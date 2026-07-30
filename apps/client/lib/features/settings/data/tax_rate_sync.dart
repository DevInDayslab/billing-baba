import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

/// Applies pull/ack updates for `entity_type: tax_rates` into Drift.
class TaxRateSync {
  TaxRateSync(this._db);

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
      _db.taxRatesLocal,
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
          .into(_db.taxRatesLocal)
          .insertOnConflictUpdate(
            TaxRatesLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              name: existing?.name ?? _str(payload, 'name') ?? '',
              rate: existing?.rate ?? _str(payload, 'rate') ?? '0',
              isDefault: Value(existing?.isDefault ?? false),
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

    final name = _str(payload, 'name');
    final rate = _str(payload, 'rate');
    await _db
        .into(_db.taxRatesLocal)
        .insertOnConflictUpdate(
          TaxRatesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: (name != null && name.isNotEmpty)
                ? name
                : (existing?.name ?? ''),
            rate: (rate != null && rate.isNotEmpty)
                ? rate
                : (existing?.rate ?? '0'),
            isDefault: Value(
              _bool(payload, 'is_default') ?? existing?.isDefault ?? false,
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
      _db.taxRatesLocal,
    )..where((t) => t.id.equals(entityId))).write(
      TaxRatesLocalCompanion(
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

  static bool? _bool(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    return null;
  }
}
