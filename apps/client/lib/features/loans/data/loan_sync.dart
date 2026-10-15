import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class LoanAccountSync {
  LoanAccountSync(this._db);

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
      _db.loanAccountsLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    await _db.into(_db.loanAccountsLocal).insertOnConflictUpdate(
          LoanAccountsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: _str(payload, 'name') ?? existing?.name ?? '',
            lenderName: Value(
              _str(payload, 'lender_name') ?? existing?.lenderName,
            ),
            accountNumber: Value(
              _str(payload, 'account_number') ?? existing?.accountNumber,
            ),
            description: Value(
              _str(payload, 'description') ?? existing?.description,
            ),
            openingOutstanding: Value(
              _str(payload, 'opening_outstanding') ??
                  existing?.openingOutstanding ??
                  '0',
            ),
            openingBalanceAsOf: _str(payload, 'opening_balance_as_of') ??
                existing?.openingBalanceAsOf ??
                updatedAt.toUtc().toIso8601String().substring(0, 10),
            interestRate: Value(
              _str(payload, 'interest_rate') ?? existing?.interestRate,
            ),
            termMonths: Value(
              _int(payload, 'term_months') ?? existing?.termMonths,
            ),
            receivedBankAccountId: Value(
              _str(payload, 'received_bank_account_id') ??
                  existing?.receivedBankAccountId,
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
    return (_db.update(_db.loanAccountsLocal)
          ..where((t) => t.id.equals(entityId)))
        .write(
      LoanAccountsLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }
}

class LoanTransactionSync {
  LoanTransactionSync(this._db);

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
      _db.loanTransactionsLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    await _db.into(_db.loanTransactionsLocal).insertOnConflictUpdate(
          LoanTransactionsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            loanAccountId:
                _str(payload, 'loan_account_id') ?? existing?.loanAccountId ?? '',
            transactionType: _str(payload, 'transaction_type') ??
                existing?.transactionType ??
                'increase',
            transactionDate: _str(payload, 'transaction_date') ??
                existing?.transactionDate ??
                updatedAt.toUtc().toIso8601String().substring(0, 10),
            principalAmount: Value(
              _str(payload, 'principal_amount') ??
                  existing?.principalAmount ??
                  '0',
            ),
            interestAmount: Value(
              _str(payload, 'interest_amount') ??
                  existing?.interestAmount ??
                  '0',
            ),
            chargesAmount: Value(
              _str(payload, 'charges_amount') ??
                  existing?.chargesAmount ??
                  '0',
            ),
            bankAccountId:
                _str(payload, 'bank_account_id') ?? existing?.bankAccountId ?? '',
            description: Value(
              _str(payload, 'description') ?? existing?.description,
            ),
            referenceNumber: Value(
              _str(payload, 'reference_number') ?? existing?.referenceNumber,
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
    return (_db.update(_db.loanTransactionsLocal)
          ..where((t) => t.id.equals(entityId)))
        .write(
      LoanTransactionsLocalCompanion(
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

int? _int(Map<String, dynamic>? payload, String key) {
  final value = payload?[key];
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
