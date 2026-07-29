import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

/// Applies pull/ack updates for `entity_type: unit_definitions` into Drift.
class UnitSync {
  UnitSync(this._db);

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
    final existing = await (_db.select(_db.unitDefinitionsLocal)
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
      await _db.into(_db.unitDefinitionsLocal).insertOnConflictUpdate(
            UnitDefinitionsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              name: existing?.name ?? _str(payload, 'name') ?? '',
              shortName:
                  existing?.shortName ?? _str(payload, 'short_name') ?? '',
              symbol: Value(existing?.symbol),
              decimalPlaces: Value(existing?.decimalPlaces ?? 0),
              isSystem: Value(existing?.isSystem ?? false),
              isActive: Value(existing?.isActive ?? true),
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
    final shortName = _str(payload, 'short_name');
    await _db.into(_db.unitDefinitionsLocal).insertOnConflictUpdate(
          UnitDefinitionsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: (name != null && name.isNotEmpty)
                ? name
                : (existing?.name ?? ''),
            shortName: (shortName != null && shortName.isNotEmpty)
                ? shortName
                : (existing?.shortName ?? ''),
            symbol: Value(_str(payload, 'symbol') ?? existing?.symbol),
            decimalPlaces: Value(
              _int(payload, 'decimal_places') ?? existing?.decimalPlaces ?? 0,
            ),
            isSystem: Value(
              _bool(payload, 'is_system') ?? existing?.isSystem ?? false,
            ),
            isActive: Value(
              _bool(payload, 'is_active') ?? existing?.isActive ?? true,
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
    return (_db.update(_db.unitDefinitionsLocal)
          ..where((t) => t.id.equals(entityId)))
        .write(
      UnitDefinitionsLocalCompanion(
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

  static int? _int(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
