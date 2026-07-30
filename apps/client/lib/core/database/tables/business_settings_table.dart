import 'package:drift/drift.dart';

/// Local mirror of Postgres `business_settings`.
@DataClassName('BusinessSettingsTableData')
class BusinessSettingsLocal extends Table {
  @override
  String get tableName => 'business_settings_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get valuationMethod =>
      text().withDefault(const Constant('average'))();
  TextColumn get defaultTaxType => text().withDefault(const Constant('none'))();
  TextColumn get invoiceTerms => text().nullable()();
  BoolColumn get enablePriceConflictAlerts =>
      boolean().withDefault(const Constant(true))();
  TextColumn get creditLimitAction =>
      text().withDefault(const Constant('warn'))();
  /// JSON object string for pricing tier labels.
  TextColumn get pricingTierLabels => text().nullable()();
  TextColumn get defaultInvoiceTaxRate => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
