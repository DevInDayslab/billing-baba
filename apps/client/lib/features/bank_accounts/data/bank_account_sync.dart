import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class BankAccountSync {
  BankAccountSync(this._db);

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
      _db.bankAccountsLocal,
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
          .into(_db.bankAccountsLocal)
          .insertOnConflictUpdate(
            BankAccountsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              type: existing?.type ?? _str(payload, 'type') ?? 'bank',
              displayName:
                  existing?.displayName ?? _str(payload, 'display_name') ?? '',
              openingBalanceAsOf:
                  existing?.openingBalanceAsOf ??
                  _str(payload, 'opening_balance_as_of') ??
                  '1970-01-01',
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

    await _db.into(_db.bankAccountsLocal).insertOnConflictUpdate(
          BankAccountsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            type: _str(payload, 'type') ?? existing?.type ?? 'bank',
            displayName: _str(payload, 'display_name') ??
                existing?.displayName ??
                '',
            bankName: Value(_str(payload, 'bank_name') ?? existing?.bankName),
            accountNumber: Value(
              _str(payload, 'account_number') ?? existing?.accountNumber,
            ),
            ifsc: Value(_str(payload, 'ifsc') ?? existing?.ifsc),
            upiId: Value(_str(payload, 'upi_id') ?? existing?.upiId),
            openingBalance: Value(
              _str(payload, 'opening_balance') ??
                  existing?.openingBalance ??
                  '0',
            ),
            openingBalanceAsOf: _str(payload, 'opening_balance_as_of') ??
                existing?.openingBalanceAsOf ??
                '1970-01-01',
            isDefault: Value(
              _bool(payload, 'is_default') ?? existing?.isDefault ?? false,
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
    return (_db.update(
      _db.bankAccountsLocal,
    )..where((t) => t.id.equals(entityId))).write(
      BankAccountsLocalCompanion(
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
