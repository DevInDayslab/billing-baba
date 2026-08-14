import 'package:flutter/material.dart';

/// In-app notification categories supported in this milestone.
enum NotificationType {
  businessReminder,
  paymentReminder,
  subscriptionExpiry,
  backupReminder,
  syncFailed,
  syncCompleted,
  importCompleted,
  exportCompleted,
  lowStock,
  outstandingReminder,
  invoiceShared,
  invoicePaid,
  purchaseDue,
  saleDue,
  appUpdate,
  welcome;

  String get label => switch (this) {
    NotificationType.businessReminder => 'Business Reminder',
    NotificationType.paymentReminder => 'Payment Reminder',
    NotificationType.subscriptionExpiry => 'Subscription Expiry',
    NotificationType.backupReminder => 'Backup Reminder',
    NotificationType.syncFailed => 'Sync Failed',
    NotificationType.syncCompleted => 'Sync Completed',
    NotificationType.importCompleted => 'Import Completed',
    NotificationType.exportCompleted => 'Export Completed',
    NotificationType.lowStock => 'Low Stock',
    NotificationType.outstandingReminder => 'Outstanding Reminder',
    NotificationType.invoiceShared => 'Invoice Shared',
    NotificationType.invoicePaid => 'Invoice Paid',
    NotificationType.purchaseDue => 'Purchase Due',
    NotificationType.saleDue => 'Sale Due',
    NotificationType.appUpdate => 'App Update',
    NotificationType.welcome => 'Welcome',
  };

  NotificationFilterCategory get filterCategory => switch (this) {
    NotificationType.paymentReminder ||
    NotificationType.invoicePaid ||
    NotificationType.invoiceShared ||
    NotificationType.saleDue ||
    NotificationType.purchaseDue ||
    NotificationType.outstandingReminder => NotificationFilterCategory.transaction,
    _ => NotificationFilterCategory.app,
  };

  IconData get icon => switch (this) {
    NotificationType.businessReminder => Icons.alarm_outlined,
    NotificationType.paymentReminder => Icons.payments_outlined,
    NotificationType.subscriptionExpiry => Icons.card_membership_outlined,
    NotificationType.backupReminder => Icons.cloud_upload_outlined,
    NotificationType.syncFailed => Icons.sync_problem_outlined,
    NotificationType.syncCompleted => Icons.sync_outlined,
    NotificationType.importCompleted => Icons.file_download_outlined,
    NotificationType.exportCompleted => Icons.file_upload_outlined,
    NotificationType.lowStock => Icons.inventory_2_outlined,
    NotificationType.outstandingReminder => Icons.account_balance_wallet_outlined,
    NotificationType.invoiceShared => Icons.share_outlined,
    NotificationType.invoicePaid => Icons.check_circle_outline,
    NotificationType.purchaseDue => Icons.shopping_cart_outlined,
    NotificationType.saleDue => Icons.receipt_long_outlined,
    NotificationType.appUpdate => Icons.system_update_outlined,
    NotificationType.welcome => Icons.waving_hand_outlined,
  };

  static NotificationType? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final type in NotificationType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }
}

/// Filter tabs shown on the notification center.
enum NotificationFilter {
  appNotifications('App Notifications'),
  transactions('Transactions');

  const NotificationFilter(this.label);

  final String label;

  static NotificationFilter? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final filter in NotificationFilter.values) {
      if (filter.name == raw) return filter;
    }
    return null;
  }
}

enum NotificationFilterCategory {
  app,
  transaction,
}

/// Reminder recurrence for scheduled local notifications.
enum ReminderRecurrence {
  once,
  daily,
}

/// Local notification channel identifiers.
enum NotificationChannelId {
  general('billing_baba_general', 'Billing Baba', 'General business alerts'),
  reminder('billing_baba_reminder', 'Reminders', 'Business and invoice reminders'),
  sync('billing_baba_sync', 'Sync', 'Sync status notifications');

  const NotificationChannelId(this.id, this.name, this.description);

  final String id;
  final String name;
  final String description;
}
