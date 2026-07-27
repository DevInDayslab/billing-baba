import 'package:drift/drift.dart';

/// Local mirror of Postgres `parties` (master-data sync entity).
@DataClassName('PartyTableData')
class PartiesLocal extends Table {
  @override
  String get tableName => 'parties_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get legalName => text().nullable()();
  TextColumn get alias => text().nullable()();
  TextColumn get mobile => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get partyGroup => text().nullable()();
  TextColumn get areaCode => text().nullable()();
  TextColumn get partyType => text().withDefault(const Constant('customer'))();
  TextColumn get partyCategory => text().nullable()();
  TextColumn get pricingTier => text().withDefault(const Constant('tier_1'))();
  TextColumn get gstin => text().nullable()();
  TextColumn get stateCode => text().nullable()();
  TextColumn get areaId => text().nullable()();
  TextColumn get creditLimit => text().withDefault(const Constant('0'))();
  TextColumn get openingBalance => text().withDefault(const Constant('0'))();
  TextColumn get hiddenLedgerBalance => text().withDefault(const Constant('0'))();
  TextColumn get profileImageUrl => text().nullable()();
  TextColumn get profileMediaAssetId => text().nullable()();
  TextColumn get connectedSince => text().nullable()();
  TextColumn get notes => text().nullable()();
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
