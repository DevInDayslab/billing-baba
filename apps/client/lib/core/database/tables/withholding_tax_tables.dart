import 'package:drift/drift.dart';

@DataClassName('WithholdingTaxSectionLocalData')
class WithholdingTaxSectionsLocal extends Table {
  @override
  String get tableName => 'withholding_tax_sections_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get kind => text()();
  TextColumn get code => text()();
  TextColumn get description => text()();
  TextColumn get rate => text()();
  TextColumn get applicableOn => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isPreloaded => boolean().withDefault(const Constant(false))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('WithholdingTaxEntryLocalData')
class WithholdingTaxEntriesLocal extends Table {
  @override
  String get tableName => 'withholding_tax_entries_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get kind => text()();
  TextColumn get direction => text()();
  TextColumn get sectionId => text().nullable()();
  TextColumn get sectionCode => text()();
  TextColumn get rate => text()();
  TextColumn get baseAmount => text()();
  TextColumn get taxAmount => text()();
  TextColumn get partyId => text().nullable()();
  TextColumn get partyPan => text().nullable()();
  TextColumn get partyName => text().nullable()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get entryDate => text()();
  TextColumn get depositId => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TaxDepositLocalData')
class TaxDepositsLocal extends Table {
  @override
  String get tableName => 'tax_deposits_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get kind => text()();
  TextColumn get bsrCode => text()();
  TextColumn get challanSerial => text()();
  TextColumn get depositDate => text()();
  TextColumn get amount => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
