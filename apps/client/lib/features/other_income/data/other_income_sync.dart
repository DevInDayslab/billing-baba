import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class IncomeItemSync {
  IncomeItemSync(this._db);

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
      _db.incomeItemsLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    await _db.into(_db.incomeItemsLocal).insertOnConflictUpdate(
          IncomeItemsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: _str(payload, 'name') ?? existing?.name ?? '',
            hsnSac: Value(_str(payload, 'hsn_sac') ?? existing?.hsnSac),
            price: Value(_str(payload, 'price') ?? existing?.price ?? '0'),
            priceIsTaxInclusive: Value(
              payload?['price_is_tax_inclusive'] == true ||
                  (existing?.priceIsTaxInclusive ?? false),
            ),
            taxRate: Value(
              _str(payload, 'tax_rate') ?? existing?.taxRate ?? '0',
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
    return (_db.update(_db.incomeItemsLocal)
          ..where((t) => t.id.equals(entityId)))
        .write(
      IncomeItemsLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }
}

class IncomeCategorySync {
  IncomeCategorySync(this._db);

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
      _db.incomeCategoriesLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    await _db.into(_db.incomeCategoriesLocal).insertOnConflictUpdate(
          IncomeCategoriesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: _str(payload, 'name') ?? existing?.name ?? '',
            categoryType: Value(
              _str(payload, 'category_type') ??
                  existing?.categoryType ??
                  'indirect',
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
    return (_db.update(_db.incomeCategoriesLocal)
          ..where((t) => t.id.equals(entityId)))
        .write(
      IncomeCategoriesLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }
}

class OtherIncomeSync {
  OtherIncomeSync(this._db);

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
      _db.otherIncomesLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    await _db.into(_db.otherIncomesLocal).insertOnConflictUpdate(
          OtherIncomesLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            categoryId:
                _str(payload, 'category_id') ?? existing?.categoryId ?? '',
            incomeItemId: Value(
              _str(payload, 'income_item_id') ?? existing?.incomeItemId,
            ),
            amount: _str(payload, 'amount') ?? existing?.amount ?? '0',
            quantity: Value(_str(payload, 'quantity') ?? existing?.quantity),
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
            incomeDate: _str(payload, 'income_date') ??
                existing?.incomeDate ??
                updatedAt.toUtc().toIso8601String().substring(0, 10),
            paymentMode: Value(
              _str(payload, 'payment_mode') ?? existing?.paymentMode,
            ),
            bankAccountId: Value(
              _str(payload, 'bank_account_id') ?? existing?.bankAccountId,
            ),
            dueDate: Value(_str(payload, 'due_date') ?? existing?.dueDate),
            balanceDue: Value(
              _str(payload, 'balance_due') ?? existing?.balanceDue,
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
    return (_db.update(_db.otherIncomesLocal)
          ..where((t) => t.id.equals(entityId)))
        .write(
      OtherIncomesLocalCompanion(
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
