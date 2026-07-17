import 'package:billing_baba/features/tasks/models/task_category.dart';

/// Personal dashboard reminder — not a project-management task.
enum TaskStatus { pending, completed, overdue }

enum TaskFilter { all, pending, completed }

enum TaskReminderBadge { today, tomorrow, overdue }

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.category,
    this.reminderAt,
    this.isCompleted = false,
    this.isPinned = false,
    this.completedAt,
    this.linkedInvoiceId,
    this.linkedPartyId,
    this.linkedPurchaseId,
    this.linkedProductId,
    this.attachmentIds = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] != null
          ? TaskCategoryStyle.fromJson(json['category'] as String?)
          : null,
      reminderAt: _parseDate(json['reminder_at']),
      isCompleted: json['is_completed'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      completedAt: _parseDate(json['completed_at']),
      linkedInvoiceId: json['linked_invoice_id'] as String?,
      linkedPartyId: json['linked_party_id'] as String?,
      linkedPurchaseId: json['linked_purchase_id'] as String?,
      linkedProductId: json['linked_product_id'] as String?,
      attachmentIds:
          (json['attachment_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  final String id;
  final String title;
  final String? description;
  final TaskCategory? category;
  final DateTime? reminderAt;
  final bool isCompleted;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? linkedInvoiceId;
  final String? linkedPartyId;
  final String? linkedPurchaseId;
  final String? linkedProductId;
  final List<String> attachmentIds;

  static const maxPinned = 5;

  static const quickTemplates = <String>[
    'Call supplier',
    'Follow customer payment',
    'Deposit cash',
    'GST filing',
    'Stock counting',
  ];

  TaskStatus status({DateTime? now}) {
    if (isCompleted) return TaskStatus.completed;
    final reminder = reminderAt;
    if (reminder == null) return TaskStatus.pending;
    final today = _dateOnly(now ?? DateTime.now());
    if (_dateOnly(reminder).isBefore(today)) return TaskStatus.overdue;
    return TaskStatus.pending;
  }

  TaskReminderBadge? reminderBadge({DateTime? now}) {
    if (isCompleted || reminderAt == null) return null;
    final today = _dateOnly(now ?? DateTime.now());
    final reminderDay = _dateOnly(reminderAt!);
    if (reminderDay.isBefore(today)) return TaskReminderBadge.overdue;
    if (reminderDay == today) return TaskReminderBadge.today;
    if (reminderDay == today.add(const Duration(days: 1))) {
      return TaskReminderBadge.tomorrow;
    }
    return null;
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    TaskCategory? category,
    bool clearCategory = false,
    DateTime? reminderAt,
    bool clearReminderAt = false,
    bool? isCompleted,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? linkedInvoiceId,
    String? linkedPartyId,
    String? linkedPurchaseId,
    String? linkedProductId,
    List<String>? attachmentIds,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      category: clearCategory ? null : (category ?? this.category),
      reminderAt: clearReminderAt ? null : (reminderAt ?? this.reminderAt),
      isCompleted: isCompleted ?? this.isCompleted,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      linkedInvoiceId: linkedInvoiceId ?? this.linkedInvoiceId,
      linkedPartyId: linkedPartyId ?? this.linkedPartyId,
      linkedPurchaseId: linkedPurchaseId ?? this.linkedPurchaseId,
      linkedProductId: linkedProductId ?? this.linkedProductId,
      attachmentIds: attachmentIds ?? this.attachmentIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (description != null) 'description': description,
    if (category != null) 'category': category!.toJson(),
    if (reminderAt != null) 'reminder_at': reminderAt!.toIso8601String(),
    'is_completed': isCompleted,
    'is_pinned': isPinned,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    if (linkedInvoiceId != null) 'linked_invoice_id': linkedInvoiceId,
    if (linkedPartyId != null) 'linked_party_id': linkedPartyId,
    if (linkedPurchaseId != null) 'linked_purchase_id': linkedPurchaseId,
    if (linkedProductId != null) 'linked_product_id': linkedProductId,
    'attachment_ids': attachmentIds,
  };

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

/// Sort + filter helpers kept out of widgets.
abstract final class TaskSort {
  static List<TaskModel> filterAndSort(
    List<TaskModel> tasks, {
    required TaskFilter filter,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final filtered = switch (filter) {
      TaskFilter.all => tasks,
      TaskFilter.pending =>
        tasks
            .where((t) => t.status(now: clock) != TaskStatus.completed)
            .toList(),
      TaskFilter.completed => tasks.where((t) => t.isCompleted).toList(),
    };

    final sorted = List<TaskModel>.from(filtered)
      ..sort((a, b) => _compare(a, b, clock));
    return sorted;
  }

  static int _compare(TaskModel a, TaskModel b, DateTime now) {
    // Pinned first (among filtered set).
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;

    final bucketA = _bucket(a, now);
    final bucketB = _bucket(b, now);
    if (bucketA != bucketB) return bucketA.compareTo(bucketB);

    final reminderA = a.reminderAt;
    final reminderB = b.reminderAt;
    if (reminderA != null && reminderB != null) {
      final byReminder = reminderA.compareTo(reminderB);
      if (byReminder != 0) return byReminder;
    } else if (reminderA != null) {
      return -1;
    } else if (reminderB != null) {
      return 1;
    }

    return b.createdAt.compareTo(a.createdAt);
  }

  /// 0 overdue, 1 pending+reminder, 2 pending, 3 completed.
  static int _bucket(TaskModel task, DateTime now) {
    final status = task.status(now: now);
    if (status == TaskStatus.completed) return 3;
    if (status == TaskStatus.overdue) return 0;
    if (task.reminderAt != null) return 1;
    return 2;
  }
}
