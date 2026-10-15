import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:drift/drift.dart';

class LoanAccountLocalSource {
  LoanAccountLocalSource(this._db);

  final AppDatabase _db;

  Stream<List<LoanAccountDto>> watchActive(String businessId) {
    return (_db.select(_db.loanAccountsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(_toDto).toList());
  }

  Future<List<LoanAccountDto>> listActive(String businessId) async {
    final rows =
        await (_db.select(_db.loanAccountsLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
    return rows.map(_toDto).toList();
  }

  Future<LoanAccountDto?> getById(String id) async {
    final row = await (_db.select(
      _db.loanAccountsLocal,
    )..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
    return row == null ? null : _toDto(row);
  }

  LoanAccountDto _toDto(LoanAccountTableData row) {
    return LoanAccountDto(
      id: row.id,
      name: row.name,
      lenderName: row.lenderName,
      accountNumber: row.accountNumber,
      description: row.description,
      openingOutstanding: row.openingOutstanding,
      openingBalanceAsOf: row.openingBalanceAsOf,
      interestRate: row.interestRate,
      termMonths: row.termMonths,
      receivedBankAccountId: row.receivedBankAccountId,
    );
  }
}
