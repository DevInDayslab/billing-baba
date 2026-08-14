import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class ExpenseCategorySync {
  ExpenseCategorySync(this._db);

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
      _db.expenseCategoriesLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    await _db
        .into(_db.expenseCategoriesLocal)
        .insertOnConflictUpdate(
          ExpenseCategoriesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: _str(payload, 'name') ?? existing?.name ?? '',
            categoryType: Value(
              _str(payload, 'category_type') ??
                  existing?.categoryType ??
                  'direct',
            ),
            isSystem: Value(
              payload?['is_system'] == true || (existing?.isSystem ?? false),
            ),
            syncVersion: Value(syncVersion),
            isDeleted: Value(isDeleted),
            createdAt: existing?.createdAt ?? updatedAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(
              isDeleted ? (deletedAt ?? updatedAt).toUtc() : null,
            ),
            deviceId: Value(deviceId ?? existing?.deviceId),
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
      _db.expenseCategoriesLocal,
    )..where((t) => t.id.equals(entityId))).write(
      ExpenseCategoriesLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }
}

class ExpenseSync {
  ExpenseSync(this._db);

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
      _db.expensesLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    await _db
        .into(_db.expensesLocal)
        .insertOnConflictUpdate(
          ExpensesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            categoryId:
                _str(payload, 'category_id') ?? existing?.categoryId ?? '',
            partyId: Value(_str(payload, 'party_id') ?? existing?.partyId),
            amount: _str(payload, 'amount') ?? existing?.amount ?? '0',
            taxAmount: Value(
              _str(payload, 'tax_amount') ?? existing?.taxAmount ?? '0',
            ),
            taxRate: Value(
              _str(payload, 'tax_rate') ?? existing?.taxRate ?? '0',
            ),
            description: Value(
              _str(payload, 'description') ?? existing?.description,
            ),
            notes: Value(_str(payload, 'notes') ?? existing?.notes),
            referenceNumber: Value(
              _str(payload, 'reference_number') ?? existing?.referenceNumber,
            ),
            expenseDate:
                _str(payload, 'expense_date') ??
                existing?.expenseDate ??
                updatedAt.toUtc().toIso8601String().substring(0, 10),
            paymentMode: Value(
              _str(payload, 'payment_mode') ?? existing?.paymentMode,
            ),
            syncVersion: Value(syncVersion),
            isDeleted: Value(isDeleted),
            createdAt: existing?.createdAt ?? updatedAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(
              isDeleted ? (deletedAt ?? updatedAt).toUtc() : null,
            ),
            deviceId: Value(deviceId ?? existing?.deviceId),
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
      _db.expensesLocal,
    )..where((t) => t.id.equals(entityId))).write(
      ExpensesLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }
}

String? _str(Map<String, dynamic>? payload, String key) {
  final value = payload?[key];
  if (value == null) return null;
  return value.toString();
}
