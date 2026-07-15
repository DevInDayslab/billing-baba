import 'package:drift/drift.dart';

@DataClassName('DealTableData')
class Deals extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  TextColumn get stage => text()();
  TextColumn get accountName => text().nullable()();
  TextColumn get assignedTo => text().nullable()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  TextColumn get expectedCloseDate => text().nullable()();
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
