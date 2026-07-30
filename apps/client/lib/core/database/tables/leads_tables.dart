import 'package:drift/drift.dart';

@DataClassName('LeadTableData')
class Leads extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get company => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get leadSource => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('new'))();
  TextColumn get assignedTo => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get deviceId => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get createdAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LeadActivityTableData')
class LeadActivities extends Table {
  TextColumn get id => text()();
  TextColumn get leadId => text()();
  TextColumn get businessId => text()();
  TextColumn get type => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get addedBy => text().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();
  TextColumn get deviceId => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get createdAt => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
