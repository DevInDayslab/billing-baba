import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_model.dart';
import 'package:billing_baba/features/notifications/domain/models/notification_type.dart';
import 'package:go_router/go_router.dart';

/// Resolves notification tap targets into app routes.
abstract final class NotificationNavigation {
  static String? resolveRoute(AppNotification notification) {
    if (notification.actionRoute != null &&
        notification.actionRoute!.isNotEmpty) {
      return _withPayload(
        notification.actionRoute!,
        notification.actionPayload,
      );
    }

    return switch (notification.type) {
      NotificationType.paymentReminder ||
      NotificationType.invoicePaid => AppRoutes.addPaymentIn,
      NotificationType.saleDue ||
      NotificationType.invoiceShared => AppRoutes.saleInvoices,
      NotificationType.purchaseDue => AppRoutes.purchaseBills,
      NotificationType.lowStock => AppRoutes.items,
      NotificationType.syncFailed ||
      NotificationType.syncCompleted => AppRoutes.collaborationSyncShare,
      NotificationType.subscriptionExpiry => AppRoutes.plansPricing,
      NotificationType.backupReminder => AppRoutes.settingsBackup,
      NotificationType.importCompleted => AppRoutes.utilitiesImportItems,
      NotificationType.exportCompleted => AppRoutes.reports,
      NotificationType.businessReminder ||
      NotificationType.outstandingReminder => AppRoutes.parties,
      NotificationType.appUpdate => AppRoutes.settingsTab('about'),
      NotificationType.welcome => AppRoutes.home,
    };
  }

  static void navigate(GoRouter router, AppNotification notification) {
    final route = resolveRoute(notification);
    if (route == null) return;
    router.push(route);
  }

  static String _withPayload(String route, String? payload) {
    if (payload == null || payload.isEmpty) return route;

    if (route == AppRoutes.viewSale || route == AppRoutes.editSale) {
      return '$route/$payload';
    }
    if (route == AppRoutes.editPurchase) {
      return '$route/$payload';
    }
    if (route == AppRoutes.itemsDetail) {
      return '$route/$payload';
    }
    if (route.contains('?')) {
      return '$route&id=$payload';
    }
    return '$route?id=$payload';
  }
}

/// Groups notifications by Today / Yesterday / Earlier.
enum NotificationDateGroup {
  today('Today'),
  yesterday('Yesterday'),
  earlier('Earlier');

  const NotificationDateGroup(this.label);

  final String label;

  static NotificationDateGroup forDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return NotificationDateGroup.today;
    if (diff == 1) return NotificationDateGroup.yesterday;
    return NotificationDateGroup.earlier;
  }
}

String formatNotificationTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24 &&
      NotificationDateGroup.forDate(dateTime) == NotificationDateGroup.today) {
    return '${diff.inHours} hr ago';
  }

  final group = NotificationDateGroup.forDate(dateTime);
  if (group == NotificationDateGroup.yesterday) return 'Yesterday';

  if (now.year == dateTime.year) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }

  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
