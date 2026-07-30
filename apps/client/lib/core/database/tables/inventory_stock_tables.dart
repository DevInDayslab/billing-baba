import 'package:drift/drift.dart';

@DataClassName('InventoryMovementLocalData')
@TableIndex(name: 'idx_movements_local_business', columns: {#businessId})
@TableIndex(name: 'idx_movements_local_item', columns: {#itemId})
@TableIndex(name: 'idx_movements_local_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_movements_local_type', columns: {#movementType})
class InventoryMovementsLocal extends Table {
  @override
  String get tableName => 'inventory_movements_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get itemId => text()();
  TextColumn get godownId => text()();
  TextColumn get documentId => text().nullable()();
  TextColumn get documentType => text().nullable()();
  TextColumn get movementType => text()();
  TextColumn get quantity => text()();
  TextColumn get beforeQuantity => text().nullable()();
  TextColumn get afterQuantity => text().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get partyName => text().nullable()();
  TextColumn get costPerUnit => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get createdByName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StockLevelLocalData')
@TableIndex(name: 'idx_stock_levels_local_business', columns: {#businessId})
@TableIndex(name: 'idx_stock_levels_local_item', columns: {#itemId})
class StockLevelsLocal extends Table {
  @override
  String get tableName => 'stock_levels_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get itemId => text()();
  TextColumn get godownId => text()();
  TextColumn get currentQuantity => text().withDefault(const Constant('0'))();
  TextColumn get reservedQuantity => text().withDefault(const Constant('0'))();
  TextColumn get availableQuantity => text().withDefault(const Constant('0'))();
  TextColumn get averageCost => text().withDefault(const Constant('0'))();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
