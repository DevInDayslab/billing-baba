import 'package:drift/drift.dart';

/// Local-only queue for offline mutations awaiting background sync.
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get mutationId => text()();
  TextColumn get kind => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get businessId => text()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get commandId => text().nullable()();
  TextColumn get status => text()();
  IntColumn get priority => integer().withDefault(const Constant(1))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {mutationId},
  ];
}
