import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Wraps [flutter_local_notifications] for mobile push-style alerts.
class LocalNotificationPlatformService {
  LocalNotificationPlatformService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || !AppPlatform.current.isMobile) return;

    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone));
    } on Object {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createAndroidChannels();
    _initialized = true;
  }

  Future<void> _createAndroidChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    for (final channel in NotificationChannelId.values) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          channel.id,
          channel.name,
          description: channel.description,
          importance: channel == NotificationChannelId.reminder
              ? Importance.high
              : Importance.defaultImportance,
        ),
      );
    }
  }

  Future<bool> requestPermission() async {
    if (!AppPlatform.current.isMobile) return false;

    if (AppPlatform.current.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }

    if (AppPlatform.current.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<bool> hasPermission() async {
    if (!AppPlatform.current.isMobile) return false;

    if (AppPlatform.current.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    }

    if (AppPlatform.current.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final settings = await ios?.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    return false;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationChannelId channel,
    bool sound = true,
    bool vibration = true,
    String? payload,
  }) async {
    if (!_initialized) return;

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel == NotificationChannelId.reminder
          ? Importance.high
          : Importance.defaultImportance,
      priority: channel == NotificationChannelId.reminder
          ? Priority.high
          : Priority.defaultPriority,
      playSound: sound,
      enableVibration: vibration,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: sound,
    );

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required NotificationChannelId channel,
    bool sound = true,
    bool vibration = true,
    String? payload,
    bool daily = false,
  }) async {
    if (!_initialized) return;

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound,
      enableVibration: vibration,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: sound,
    );

    final scheduled = tz.TZDateTime.from(scheduledAt, tz.local);
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (daily) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      return;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('Notification tapped: ${response.payload}');
    }
  }
}

/// Tracks OS permission prompt state — never re-prompt after denial.
class NotificationPermissionService {
  NotificationPermissionService(this._storage, this._platform);

  final StorageService _storage;
  final LocalNotificationPlatformService _platform;

  bool get hasAsked =>
      _storage.read(StorageKeys.notificationPermissionAsked) == 'true';

  bool get userDenied =>
      _storage.read(StorageKeys.notificationPermissionDenied) == 'true';

  Future<bool> isGranted() => _platform.hasPermission();

  Future<bool> requestIfNeeded({required bool force}) async {
    if (userDenied && !force) return false;
    if (!force && hasAsked) {
      return _platform.hasPermission();
    }

    await _storage.write(StorageKeys.notificationPermissionAsked, 'true');
    final granted = await _platform.requestPermission();
    if (!granted) {
      await _storage.write(StorageKeys.notificationPermissionDenied, 'true');
    } else {
      await _storage.write(StorageKeys.notificationPermissionDenied, 'false');
    }
    return granted;
  }

  Future<void> markLater() async {
    await _storage.write(StorageKeys.notificationPermissionAsked, 'true');
  }

  Future<void> resetDenied() async {
    await _storage.write(StorageKeys.notificationPermissionDenied, 'false');
  }
}

String encodeNotificationPayload({
  String? route,
  String? payload,
}) {
  return jsonEncode({
    'route': ?route,
    'payload': ?payload,
  });
}
