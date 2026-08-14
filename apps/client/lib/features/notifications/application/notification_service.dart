import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/features/notifications/data/local_notification_platform_service.dart';
import 'package:billing_baba/features/notifications/data/notification_local_data_source.dart';
import 'package:billing_baba/features/notifications/data/notification_repository.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_type.dart';
import 'package:uuid/uuid.dart';

/// Business logic for in-app notifications and scheduled reminders.
class NotificationService {
  NotificationService({
    required this._repository,
    required this._preferencesDataSource,
    required this._reminderDataSource,
    required LocalNotificationPlatformService platformService,
    required NotificationPermissionService permissionService,
    required this._businessIdReader,
  })  : _platform = platformService,
        _permission = permissionService;

  final NotificationRepository _repository;
  final NotificationPreferencesLocalDataSource _preferencesDataSource;
  final ScheduledReminderLocalDataSource _reminderDataSource;
  final LocalNotificationPlatformService _platform;
  final NotificationPermissionService _permission;
  final String Function() _businessIdReader;
  final _uuid = const Uuid();
  int _nextNotificationId = 1000;

  String get _businessId => _businessIdReader();

  String get _preferencesKey =>
      StorageKeys.notificationPreferencesFor(_businessId);

  String get _remindersKey => StorageKeys.scheduledRemindersFor(_businessId);

  Stream<List<AppNotification>> watchNotifications() {
    return _repository.watchAll(_businessId);
  }

  Stream<int> watchUnreadCount() {
    return _repository.watchUnreadCount(_businessId);
  }

  Future<List<AppNotification>> getNotifications() {
    return _repository.getAll(_businessId);
  }

  Future<NotificationPreferences> getPreferences() {
    return _preferencesDataSource.load(_preferencesKey);
  }

  Future<void> savePreferences(NotificationPreferences preferences) {
    return _preferencesDataSource.save(_preferencesKey, preferences);
  }

  Future<AppNotification> createNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? actionRoute,
    String? actionPayload,
    bool showSystemAlert = false,
    DateTime? createdAt,
  }) async {
    final preferences = await getPreferences();
    if (!preferences.isTypeEnabled(type)) {
      throw StateError('Notification type disabled: ${type.name}');
    }

    final notification = AppNotification(
      id: _uuid.v4(),
      businessId: _businessId,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt ?? DateTime.now(),
      actionRoute: actionRoute,
      actionPayload: actionPayload,
    );

    await _repository.insert(notification);

    if (showSystemAlert && preferences.enabled) {
      final granted = await _permission.isGranted();
      if (granted) {
        await _platform.show(
          id: _nextId(),
          title: title,
          body: body,
          channel: _channelForType(type),
          sound: preferences.sound,
          vibration: preferences.vibration,
          payload: encodeNotificationPayload(
            route: actionRoute,
            payload: actionPayload,
          ),
        );
      }
    }

    return notification;
  }

  Future<void> markRead(String id) => _repository.markRead(id);

  Future<void> markAllRead() => _repository.markAllRead(_businessId);

  Future<void> delete(String id) => _repository.delete(id);

  Future<void> deleteAll() => _repository.deleteAll(_businessId);

  Future<bool> requestPermission({bool force = false}) {
    return _permission.requestIfNeeded(force: force);
  }

  Future<bool> hasPermission() => _permission.isGranted();

  bool get permissionDenied => _permission.userDenied;

  bool get permissionAsked => _permission.hasAsked;

  Future<void> dismissPermissionPrompt() => _permission.markLater();

  Future<void> resetPermissionDenied() => _permission.resetDenied();

  Future<ScheduledReminder> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledAt,
    ReminderRecurrence recurrence = ReminderRecurrence.once,
    String? actionRoute,
    String? actionPayload,
    NotificationType type = NotificationType.businessReminder,
  }) async {
    final preferences = await getPreferences();
    if (!preferences.reminderNotifications) {
      throw StateError('Reminder notifications are disabled');
    }

    final granted = await requestPermission(force: true);
    if (!granted) {
      throw StateError('Notification permission not granted');
    }

    final reminder = ScheduledReminder(
      id: _uuid.v4(),
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      recurrence: recurrence,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
    );

    final notificationId = _nextId();
    await _platform.schedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      channel: _channelForType(type),
      sound: preferences.sound,
      vibration: preferences.vibration,
      daily: recurrence == ReminderRecurrence.daily,
      payload: encodeNotificationPayload(
        route: actionRoute,
        payload: actionPayload,
      ),
    );

    final stored = reminder.copyWith(notificationId: notificationId);
    final reminders = await _reminderDataSource.loadAll(_remindersKey);
    reminders.add(stored);
    await _reminderDataSource.saveAll(_remindersKey, reminders);

    await createNotification(
      title: title,
      body: body,
      type: type,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
      createdAt: DateTime.now(),
    );

    return stored;
  }

  Future<void> cancelReminder(String reminderId) async {
    final reminders = await _reminderDataSource.loadAll(_remindersKey);
    final reminder = reminders.cast<ScheduledReminder?>().firstWhere(
      (item) => item?.id == reminderId,
      orElse: () => null,
    );
    if (reminder?.notificationId != null) {
      await _platform.cancel(reminder!.notificationId!);
    }
    reminders.removeWhere((item) => item.id == reminderId);
    await _reminderDataSource.saveAll(_remindersKey, reminders);
  }

  Future<List<ScheduledReminder>> getScheduledReminders() {
    return _reminderDataSource.loadAll(_remindersKey);
  }

  NotificationChannelId _channelForType(NotificationType type) {
    return switch (type) {
      NotificationType.businessReminder ||
      NotificationType.paymentReminder ||
      NotificationType.outstandingReminder ||
      NotificationType.saleDue ||
      NotificationType.purchaseDue ||
      NotificationType.subscriptionExpiry ||
      NotificationType.backupReminder => NotificationChannelId.reminder,
      NotificationType.syncFailed || NotificationType.syncCompleted =>
        NotificationChannelId.sync,
      _ => NotificationChannelId.general,
    };
  }

  int _nextId() => _nextNotificationId++;
}
