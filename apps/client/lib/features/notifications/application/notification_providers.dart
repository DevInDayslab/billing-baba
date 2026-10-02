import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/notifications/application/notification_service.dart'
    as svc;
import 'package:billing_baba/features/notifications/data/local_notification_platform_service.dart';
import 'package:billing_baba/features/notifications/data/notification_local_data_source.dart';
import 'package:billing_baba/features/notifications/data/notification_repository.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
LocalNotificationPlatformService localNotificationPlatformService(Ref ref) {
  return LocalNotificationPlatformService();
}

@Riverpod(keepAlive: true)
Future<void> notificationPlatformInitializer(Ref ref) async {
  final platform = ref.watch(localNotificationPlatformServiceProvider);
  await platform.initialize();
}

@Riverpod(keepAlive: true)
Future<svc.NotificationService> notificationService(Ref ref) async {
  await ref.watch(notificationPlatformInitializerProvider.future);
  final storage = await ref.watch(storageServiceProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final platform = ref.watch(localNotificationPlatformServiceProvider);

  final permission = NotificationPermissionService(storage, platform);
  final local = NotificationLocalDataSource(db);
  final repository = NotificationRepository(local);

  return svc.NotificationService(
    repository: repository,
    preferencesDataSource: NotificationPreferencesLocalDataSource(
      storage.read,
      storage.write,
    ),
    reminderDataSource: ScheduledReminderLocalDataSource(
      storage.read,
      storage.write,
    ),
    platformService: platform,
    permissionService: permission,
    businessIdReader: () =>
        storage.read(StorageKeys.lastOpenedBusinessId) ?? '',
  );
}

@riverpod
Stream<List<AppNotification>> notificationsStream(Ref ref) async* {
  final service = await ref.watch(notificationServiceProvider.future);
  yield* service.watchNotifications();
}

@riverpod
Stream<int> notificationUnreadCount(Ref ref) async* {
  final service = await ref.watch(notificationServiceProvider.future);
  yield* service.watchUnreadCount();
}

@riverpod
class NotificationFilterController extends _$NotificationFilterController {
  @override
  Future<NotificationFilter> build() async {
    final storage = await ref.watch(storageServiceProvider.future);
    final saved = NotificationFilter.tryParse(
      storage.read(StorageKeys.notificationFilter),
    );
    return saved ?? NotificationFilter.appNotifications;
  }

  Future<void> setFilter(NotificationFilter filter) async {
    state = AsyncData(filter);
    final storage = await ref.read(storageServiceProvider.future);
    await storage.write(StorageKeys.notificationFilter, filter.name);
  }
}

@riverpod
class NotificationPreferencesController
    extends _$NotificationPreferencesController {
  @override
  Future<NotificationPreferences> build() async {
    final service = await ref.watch(notificationServiceProvider.future);
    return service.getPreferences();
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    final service = await ref.read(notificationServiceProvider.future);
    await service.savePreferences(preferences);
    state = AsyncData(preferences);
  }
}

@riverpod
class NotificationPermissionState extends _$NotificationPermissionState {
  @override
  Future<bool> build() async {
    final service = await ref.watch(notificationServiceProvider.future);
    return service.hasPermission();
  }

  Future<bool> request({bool force = false}) async {
    final service = await ref.read(notificationServiceProvider.future);
    final granted = await service.requestPermission(force: force);
    state = AsyncData(granted);
    return granted;
  }

  Future<void> dismiss() async {
    final service = await ref.read(notificationServiceProvider.future);
    await service.dismissPermissionPrompt();
  }
}

@riverpod
class NotificationActions extends _$NotificationActions {
  @override
  void build() {}

  Future<void> markRead(String id) async {
    final service = await ref.read(notificationServiceProvider.future);
    await service.markRead(id);
  }

  Future<void> markAllRead() async {
    final service = await ref.read(notificationServiceProvider.future);
    await service.markAllRead();
  }

  Future<void> delete(String id) async {
    final service = await ref.read(notificationServiceProvider.future);
    await service.delete(id);
  }

  Future<void> deleteAll() async {
    final service = await ref.read(notificationServiceProvider.future);
    await service.deleteAll();
  }

  Future<AppNotification> create({
    required String title,
    required String body,
    required NotificationType type,
    String? actionRoute,
    String? actionPayload,
    bool showSystemAlert = false,
  }) async {
    final service = await ref.read(notificationServiceProvider.future);
    return service.createNotification(
      title: title,
      body: body,
      type: type,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
      showSystemAlert: showSystemAlert,
    );
  }

  Future<ScheduledReminder> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledAt,
    ReminderRecurrence recurrence = ReminderRecurrence.once,
    String? actionRoute,
    String? actionPayload,
  }) async {
    final service = await ref.read(notificationServiceProvider.future);
    return service.scheduleReminder(
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      recurrence: recurrence,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
    );
  }
}
