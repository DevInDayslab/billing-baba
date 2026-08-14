import 'package:drift/drift.dart';

/// Local mirror of Postgres `item_alternatives` (master-data sync entity).
@DataClassName('ItemAlternativeTableData')
class ItemAlternativesLocal extends Table {
  @override
  String get tableName => 'item_alternatives_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get itemId => text()();
  TextColumn get alternativeItemId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
