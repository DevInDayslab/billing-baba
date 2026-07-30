import 'package:drift/drift.dart';

/// Local mirror of Postgres `items` (master-data sync entity).
@DataClassName('ItemTableData')
class ItemsLocal extends Table {
  @override
  String get tableName => 'items_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text().nullable()();
  TextColumn get alias => text().nullable()();
  TextColumn get searchKeywords => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get itemType => text().withDefault(const Constant('product'))();
  BoolColumn get hasStockTracking =>
      boolean().withDefault(const Constant(true))();
  TextColumn get categoryId => text().nullable()();
  TextColumn get brandId => text().nullable()();
  TextColumn get hsnCode => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get baseUnit => text().withDefault(const Constant('piece'))();
  TextColumn get mrp => text().nullable()();
  BoolColumn get isMrpOnly => boolean().withDefault(const Constant(false))();
  TextColumn get marketPrice => text().nullable()();
  TextColumn get salePrice => text().withDefault(const Constant('0'))();
  TextColumn get purchasePrice => text().withDefault(const Constant('0'))();
  TextColumn get reorderLevel => text().nullable()();
  TextColumn get defaultTaxRate => text().nullable()();
  TextColumn get primaryImageUrl => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
