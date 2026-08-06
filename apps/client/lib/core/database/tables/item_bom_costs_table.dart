import 'package:drift/drift.dart';

/// Local mirror of Postgres `item_bom_costs` (master-data sync entity).
@DataClassName('ItemBomCostTableData')
class ItemBomCostsLocal extends Table {
  @override
  String get tableName => 'item_bom_costs_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get itemId => text()();
  TextColumn get description => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
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
