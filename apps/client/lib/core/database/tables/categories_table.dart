import 'package:drift/drift.dart';

/// Local mirror of Postgres `categories` (master-data sync entity).
@DataClassName('CategoryTableData')
class CategoriesLocal extends Table {
  @override
  String get tableName => 'categories_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get name => text()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  /// Denormalized; not pushed to server.
  IntColumn get itemCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
