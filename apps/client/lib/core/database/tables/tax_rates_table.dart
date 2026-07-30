import 'package:drift/drift.dart';

/// Local mirror of Postgres `tax_rates`.
@DataClassName('TaxRateTableData')
class TaxRatesLocal extends Table {
  @override
  String get tableName => 'tax_rates_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get rate => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
