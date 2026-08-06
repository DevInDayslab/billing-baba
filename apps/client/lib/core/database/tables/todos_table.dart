import 'package:drift/drift.dart';

/// Local mirror of Postgres `todos` (sync entity).
@DataClassName('TodoTableData')
class TodosLocal extends Table {
  @override
  String get tableName => 'todos_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get category => text().nullable()();
  TextColumn get partyId => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get linkedInvoiceId => text().nullable()();
  TextColumn get linkedPurchaseId => text().nullable()();
  TextColumn get linkedProductId => text().nullable()();
  TextColumn get attachmentIdsJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
