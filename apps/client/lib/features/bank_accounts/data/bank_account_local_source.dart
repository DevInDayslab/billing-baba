import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/bank_accounts/models/bank_account_models.dart';
import 'package:drift/drift.dart';

class BankAccountLocalSource {
  BankAccountLocalSource(this._db);

  final AppDatabase _db;

  Stream<List<BankAccountDto>> watchActive(String businessId) {
    return (_db.select(_db.bankAccountsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.isDeleted.equals(false) &
                t.isActive.equals(true),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.type.equals('cash'),
              mode: OrderingMode.desc,
            ),
            (t) => OrderingTerm.asc(t.displayName),
          ]))
        .watch()
        .map((rows) => rows.map(_toDto).toList());
  }

  Future<List<BankAccountDto>> listActive(String businessId) async {
    final rows =
        await (_db.select(_db.bankAccountsLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) &
                    t.isDeleted.equals(false) &
                    t.isActive.equals(true),
              )
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.type.equals('cash'),
                  mode: OrderingMode.desc,
                ),
                (t) => OrderingTerm.asc(t.displayName),
              ]))
            .get();
    return rows.map(_toDto).toList();
  }

  Future<BankAccountDto?> getById(String id) async {
    final row = await (_db.select(
      _db.bankAccountsLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDto(row);
  }

  BankAccountDto _toDto(BankAccountTableData row) {
    return BankAccountDto(
      id: row.id,
      type: row.type,
      displayName: row.displayName,
      bankName: row.bankName,
      accountNumber: row.accountNumber,
      ifsc: row.ifsc,
      upiId: row.upiId,
      openingBalance: row.openingBalance,
      openingBalanceAsOf: row.openingBalanceAsOf,
      isDefault: row.isDefault,
      isActive: row.isActive,
    );
  }
}
