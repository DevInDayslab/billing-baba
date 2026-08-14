import 'package:drift/drift.dart';

/// Local mirror of Postgres `item_bom_materials` (master-data sync entity).
@DataClassName('ItemBomMaterialTableData')
class ItemBomMaterialsLocal extends Table {
  @override
  String get tableName => 'item_bom_materials_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get itemId => text()();
  TextColumn get rawItemId => text()();
  RealColumn get qty => real()();
  TextColumn get unitId => text()();
  RealColumn get purchasePrice => real().withDefault(const Constant(0))();
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
