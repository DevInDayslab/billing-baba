import 'package:drift/drift.dart';

/// Local mirror of Postgres `unit_definitions`.
@DataClassName('UnitDefinitionTableData')
class UnitDefinitionsLocal extends Table {
  @override
  String get tableName => 'unit_definitions_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  TextColumn get symbol => text().nullable()();
  IntColumn get decimalPlaces => integer().withDefault(const Constant(0))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
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
