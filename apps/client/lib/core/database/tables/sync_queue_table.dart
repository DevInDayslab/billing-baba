import 'package:drift/drift.dart';

/// Local-only queue for offline writes awaiting background sync.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get businessId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get createdAt => text()();
}
