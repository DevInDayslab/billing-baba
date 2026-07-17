import 'package:drift/drift.dart';

@DataClassName('ContactTableData')
class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get salutation => text().nullable()();
  TextColumn get accountName => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get assignedTo => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
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

@DataClassName('ContactActivityTableData')
class ContactActivities extends Table {
  TextColumn get id => text()();
  TextColumn get contactId => text()();
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
