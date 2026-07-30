import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:flutter/material.dart';

/// Reminder category — drives icon and row colours in the to-do UI.
enum TaskCategory {
  paymentReminder,
  supplierFollowUp,
  inventoryCheck,
  compliance,
  customerFollowUp,
  general,
}

extension TaskCategoryStyle on TaskCategory {
  String get label => switch (this) {
    TaskCategory.paymentReminder => 'Payment Reminder',
    TaskCategory.supplierFollowUp => 'Supplier Follow-up',
    TaskCategory.inventoryCheck => 'Inventory Check',
    TaskCategory.compliance => 'Compliance',
    TaskCategory.customerFollowUp => 'Customer Follow-up',
    TaskCategory.general => 'Reminder',
  };

  IconData get icon => switch (this) {
    TaskCategory.paymentReminder => Icons.currency_rupee,
    TaskCategory.supplierFollowUp => Icons.shopping_bag_outlined,
    TaskCategory.inventoryCheck => Icons.inventory_2_outlined,
    TaskCategory.compliance => Icons.description_outlined,
    TaskCategory.customerFollowUp => Icons.person_outline,
    TaskCategory.general => Icons.notifications_none,
  };

  Color get iconColor => switch (this) {
    TaskCategory.paymentReminder => const Color(0xFFC2185B),
    TaskCategory.supplierFollowUp => const Color(0xFFF57F17),
    TaskCategory.inventoryCheck => const Color(0xFF2E7D32),
    TaskCategory.compliance => const Color(0xFF5E35B1),
    TaskCategory.customerFollowUp => const Color(0xFF1565C0),
    TaskCategory.general => AppColors.textSecondary,
  };

  Color get iconBackgroundColor => switch (this) {
    TaskCategory.paymentReminder => const Color(0xFFFFE4EC),
    TaskCategory.supplierFollowUp => const Color(0xFFFFF3CD),
    TaskCategory.inventoryCheck => const Color(0xFFE8F5E9),
    TaskCategory.compliance => const Color(0xFFEDE7F6),
    TaskCategory.customerFollowUp => const Color(0xFFE3F2FD),
    TaskCategory.general => const Color(0xFFF5F5F5),
  };

  /// Soft row tint used behind each task tile.
  Color get rowBackgroundColor => iconBackgroundColor.withValues(alpha: 0.55);

  String toJson() => name;

  static TaskCategory fromJson(String? value) {
    return TaskCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => TaskCategory.general,
    );
  }
}

/// Resolves category for tasks saved before the category field existed.
abstract final class TaskCategoryResolver {
  static TaskCategory resolve(TaskModel task) {
    if (task.category != null) return task.category!;

    if (task.linkedInvoiceId != null) return TaskCategory.paymentReminder;
    if (task.linkedPartyId != null) return TaskCategory.customerFollowUp;
    if (task.linkedPurchaseId != null) return TaskCategory.supplierFollowUp;
    if (task.linkedProductId != null) return TaskCategory.inventoryCheck;

    final title = task.title.toLowerCase();
    if (title.contains('payment') ||
        title.contains('collect') ||
        title.contains('₹') ||
        title.contains('receipt')) {
      return TaskCategory.paymentReminder;
    }
    if (title.contains('stock') || title.contains('inventory')) {
      return TaskCategory.inventoryCheck;
    }
    if (title.contains('gst') ||
        title.contains('compliance') ||
        title.contains('filing') ||
        title.contains('report')) {
      return TaskCategory.compliance;
    }
    if (title.contains('supplier') || title.contains('order')) {
      return TaskCategory.supplierFollowUp;
    }
    if (title.contains('customer') || title.contains('call')) {
      return TaskCategory.customerFollowUp;
    }

    return TaskCategory.general;
  }
}
