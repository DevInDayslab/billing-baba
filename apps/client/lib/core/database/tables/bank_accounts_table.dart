import 'package:drift/drift.dart';

@DataClassName('BankAccountTableData')
class BankAccountsLocal extends Table {
  @override
  String get tableName => 'bank_accounts_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get type => text()();
  TextColumn get displayName => text()();
  TextColumn get bankName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get ifsc => text().nullable()();
  TextColumn get upiId => text().nullable()();
  TextColumn get openingBalance => text().withDefault(const Constant('0'))();
  TextColumn get openingBalanceAsOf => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
