import 'package:drift/drift.dart';

@DataClassName('LoanAccountTableData')
class LoanAccountsLocal extends Table {
  @override
  String get tableName => 'loan_accounts_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get lenderName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get openingOutstanding =>
      text().withDefault(const Constant('0'))();
  TextColumn get openingBalanceAsOf => text()();
  TextColumn get interestRate => text().nullable()();
  IntColumn get termMonths => integer().nullable()();
  TextColumn get receivedBankAccountId => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LoanTransactionTableData')
class LoanTransactionsLocal extends Table {
  @override
  String get tableName => 'loan_transactions_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get loanAccountId => text()();
  TextColumn get transactionType => text()();
  TextColumn get transactionDate => text()();
  TextColumn get principalAmount =>
      text().withDefault(const Constant('0'))();
  TextColumn get interestAmount => text().withDefault(const Constant('0'))();
  TextColumn get chargesAmount => text().withDefault(const Constant('0'))();
  TextColumn get bankAccountId => text()();
  TextColumn get description => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
