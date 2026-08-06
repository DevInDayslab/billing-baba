import 'package:billing_baba/features/notifications/domain/models/notification_type.dart';

/// Domain model for an in-app notification.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.businessId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
    this.actionRoute,
    this.actionPayload,
    this.isLocal = true,
    this.futureRemoteId,
  });

  final String id;
  final String businessId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;
  final String? actionRoute;
  final String? actionPayload;
  final bool isLocal;
  final String? futureRemoteId;

  AppNotification copyWith({
    bool? read,
  }) {
    return AppNotification(
      id: id,
      businessId: businessId,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      read: read ?? this.read,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
      isLocal: isLocal,
      futureRemoteId: futureRemoteId,
    );
  }

  bool matchesFilter(NotificationFilter filter) {
    return switch (filter) {
      NotificationFilter.appNotifications =>
        type.filterCategory == NotificationFilterCategory.app,
      NotificationFilter.transactions =>
        type.filterCategory == NotificationFilterCategory.transaction,
    };
  }
}

/// User preferences for notification delivery.
class NotificationPreferences {
  const NotificationPreferences({
    this.enabled = true,
    this.reminderNotifications = true,
    this.syncNotifications = true,
    this.backupNotifications = true,
    this.subscriptionNotifications = true,
    this.lowStockNotifications = true,
    this.sound = true,
    this.vibration = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] as bool? ?? true,
      reminderNotifications: json['reminderNotifications'] as bool? ?? true,
      syncNotifications: json['syncNotifications'] as bool? ?? true,
      backupNotifications: json['backupNotifications'] as bool? ?? true,
      subscriptionNotifications:
          json['subscriptionNotifications'] as bool? ?? true,
      lowStockNotifications: json['lowStockNotifications'] as bool? ?? true,
      sound: json['sound'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
    );
  }

  final bool enabled;
  final bool reminderNotifications;
  final bool syncNotifications;
  final bool backupNotifications;
  final bool subscriptionNotifications;
  final bool lowStockNotifications;
  final bool sound;
  final bool vibration;

  NotificationPreferences copyWith({
    bool? enabled,
    bool? reminderNotifications,
    bool? syncNotifications,
    bool? backupNotifications,
    bool? subscriptionNotifications,
    bool? lowStockNotifications,
    bool? sound,
    bool? vibration,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      syncNotifications: syncNotifications ?? this.syncNotifications,
      backupNotifications: backupNotifications ?? this.backupNotifications,
      subscriptionNotifications:
          subscriptionNotifications ?? this.subscriptionNotifications,
      lowStockNotifications:
          lowStockNotifications ?? this.lowStockNotifications,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
    );
  }

  bool isTypeEnabled(NotificationType type) {
    if (!enabled) return false;
    return switch (type) {
      NotificationType.businessReminder ||
      NotificationType.paymentReminder ||
      NotificationType.outstandingReminder ||
      NotificationType.saleDue ||
      NotificationType.purchaseDue => reminderNotifications,
      NotificationType.syncFailed || NotificationType.syncCompleted =>
        syncNotifications,
      NotificationType.backupReminder => backupNotifications,
      NotificationType.subscriptionExpiry => subscriptionNotifications,
      NotificationType.lowStock => lowStockNotifications,
      _ => true,
    };
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'reminderNotifications': reminderNotifications,
    'syncNotifications': syncNotifications,
    'backupNotifications': backupNotifications,
    'subscriptionNotifications': subscriptionNotifications,
    'lowStockNotifications': lowStockNotifications,
    'sound': sound,
    'vibration': vibration,
  };
}

/// A locally scheduled reminder.
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.recurrence = ReminderRecurrence.once,
    this.actionRoute,
    this.actionPayload,
    this.notificationId,
  });

  factory ScheduledReminder.fromJson(Map<String, dynamic> json) {
    return ScheduledReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      recurrence: ReminderRecurrence.values.firstWhere(
        (value) => value.name == json['recurrence'],
        orElse: () => ReminderRecurrence.once,
      ),
      actionRoute: json['actionRoute'] as String?,
      actionPayload: json['actionPayload'] as String?,
      notificationId: json['notificationId'] as int?,
    );
  }

  final String id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final ReminderRecurrence recurrence;
  final String? actionRoute;
  final String? actionPayload;
  final int? notificationId;

  ScheduledReminder copyWith({
    int? notificationId,
  }) {
    return ScheduledReminder(
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      recurrence: recurrence,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'scheduledAt': scheduledAt.toIso8601String(),
    'recurrence': recurrence.name,
    'actionRoute': actionRoute,
    'actionPayload': actionPayload,
    'notificationId': notificationId,
  };
}
