import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_type.dart';
import 'package:drift/drift.dart';

class NotificationLocalDataSource {
  NotificationLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<AppNotification>> watchAll(String businessId) {
    return (_db.select(_db.notificationsLocal)
          ..where((row) => row.businessId.equals(businessId))
          ..orderBy([
            (row) => OrderingTerm.desc(row.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  Stream<int> watchUnreadCount(String businessId) {
    final query = _db.selectOnly(_db.notificationsLocal)
      ..addColumns([_db.notificationsLocal.id.count()])
      ..where(
        _db.notificationsLocal.businessId.equals(businessId) &
            _db.notificationsLocal.read.equals(false),
      );
    return query.watchSingle().map(
      (row) => row.read(_db.notificationsLocal.id.count()) ?? 0,
    );
  }

  Future<List<AppNotification>> getAll(String businessId) async {
    final rows =
        await (_db.select(_db.notificationsLocal)
              ..where((row) => row.businessId.equals(businessId))
              ..orderBy([
                (row) => OrderingTerm.desc(row.createdAt),
              ]))
            .get();
    return rows.map(_mapRow).toList();
  }

  Future<void> insert(AppNotification notification) {
    return _db
        .into(_db.notificationsLocal)
        .insert(
          NotificationsLocalCompanion.insert(
            id: notification.id,
            businessId: notification.businessId,
            title: notification.title,
            body: notification.body,
            type: notification.type.name,
            createdAt: notification.createdAt,
            read: Value(notification.read),
            actionRoute: Value(notification.actionRoute),
            actionPayload: Value(notification.actionPayload),
            isLocal: Value(notification.isLocal),
            futureRemoteId: Value(notification.futureRemoteId),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> markRead(String id) {
    return (_db.update(_db.notificationsLocal)
          ..where((row) => row.id.equals(id)))
        .write(const NotificationsLocalCompanion(read: Value(true)));
  }

  Future<void> markAllRead(String businessId) {
    return (_db.update(_db.notificationsLocal)..where(
          (row) => row.businessId.equals(businessId) & row.read.equals(false),
        ))
        .write(const NotificationsLocalCompanion(read: Value(true)));
  }

  Future<void> delete(String id) {
    return (_db.delete(
      _db.notificationsLocal,
    )..where((row) => row.id.equals(id))).go();
  }

  Future<void> deleteAll(String businessId) {
    return (_db.delete(
      _db.notificationsLocal,
    )..where((row) => row.businessId.equals(businessId))).go();
  }

  AppNotification _mapRow(NotificationTableData row) {
    return AppNotification(
      id: row.id,
      businessId: row.businessId,
      title: row.title,
      body: row.body,
      type:
          NotificationType.tryParse(row.type) ??
          NotificationType.businessReminder,
      createdAt: row.createdAt,
      read: row.read,
      actionRoute: row.actionRoute,
      actionPayload: row.actionPayload,
      isLocal: row.isLocal,
      futureRemoteId: row.futureRemoteId,
    );
  }
}

class NotificationPreferencesLocalDataSource {
  NotificationPreferencesLocalDataSource(this._read, this._write);

  final String? Function(String key) _read;
  final Future<void> Function(String key, String value) _write;

  Future<NotificationPreferences> load(String key) async {
    final raw = _read(key);
    if (raw == null || raw.isEmpty) {
      return const NotificationPreferences();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return NotificationPreferences.fromJson(decoded);
      }
    } on Object {
      // Fall through to defaults.
    }
    return const NotificationPreferences();
  }

  Future<void> save(String key, NotificationPreferences preferences) {
    return _write(key, jsonEncode(preferences.toJson()));
  }
}

class ScheduledReminderLocalDataSource {
  ScheduledReminderLocalDataSource(this._read, this._write);

  final String? Function(String key) _read;
  final Future<void> Function(String key, String value) _write;

  Future<List<ScheduledReminder>> loadAll(String key) async {
    final raw = _read(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ScheduledReminder.fromJson)
            .toList();
      }
    } on Object {
      return [];
    }
    return [];
  }

  Future<void> saveAll(String key, List<ScheduledReminder> reminders) {
    final encoded = jsonEncode(reminders.map((item) => item.toJson()).toList());
    return _write(key, encoded);
  }
}
