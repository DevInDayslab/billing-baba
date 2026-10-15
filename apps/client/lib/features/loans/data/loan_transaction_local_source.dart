import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/loans/models/loan_models.dart';
import 'package:drift/drift.dart';

class LoanTransactionLocalSource {
  LoanTransactionLocalSource(this._db);

  final AppDatabase _db;

  Stream<List<LoanTransactionDto>> watchForAccount({
    required String businessId,
    required String loanAccountId,
  }) {
    return (_db.select(_db.loanTransactionsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.loanAccountId.equals(loanAccountId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.transactionDate),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_toDto).toList());
  }

  LoanTransactionDto _toDto(LoanTransactionTableData row) {
    return LoanTransactionDto(
      id: row.id,
      loanAccountId: row.loanAccountId,
      transactionType: row.transactionType,
      transactionDate: row.transactionDate,
      principalAmount: row.principalAmount,
      interestAmount: row.interestAmount,
      chargesAmount: row.chargesAmount,
      bankAccountId: row.bankAccountId,
      description: row.description,
      referenceNumber: row.referenceNumber,
    );
  }
}
