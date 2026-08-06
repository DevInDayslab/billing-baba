import 'package:drift/drift.dart';

@DataClassName('NotificationTableData')
class NotificationsLocal extends Table {
  @override
  String get tableName => 'notifications_local';

  TextColumn get id => text()();
  TextColumn get businessId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  TextColumn get actionRoute => text().nullable()();
  TextColumn get actionPayload => text().nullable()();
  BoolColumn get isLocal => boolean().withDefault(const Constant(true))();
  TextColumn get futureRemoteId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
