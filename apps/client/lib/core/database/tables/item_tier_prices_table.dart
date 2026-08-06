import 'package:drift/drift.dart';

/// Local mirror of Postgres `item_tier_prices` (master-data sync entity).
@DataClassName('ItemTierPriceTableData')
class ItemTierPricesLocal extends Table {
  @override
  String get tableName => 'item_tier_prices_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get itemId => text()();
  TextColumn get pricingTier => text()();
  RealColumn get price => real()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
