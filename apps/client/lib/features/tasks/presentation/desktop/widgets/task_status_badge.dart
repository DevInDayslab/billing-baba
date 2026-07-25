import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:flutter/material.dart';

/// Compact due badge for list rows (Today / Tomorrow / Overdue only).
class TaskDueBadge extends StatelessWidget {
  const TaskDueBadge({required this.badge, super.key});

  final TaskReminderBadge badge;

  @override
  Widget build(BuildContext context) {
    final (label, backgroundColor, textColor) = switch (badge) {
      TaskReminderBadge.today => (
        'Today',
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
      TaskReminderBadge.tomorrow => (
        'Tomorrow',
        const Color(0xFFF5F5F5),
        AppColors.textSecondary,
      ),
      TaskReminderBadge.overdue => (
        'Overdue',
        const Color(0xFFFFEBEE),
        AppColors.error,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

/// Legacy badge helper kept for future expanded task views.
class TaskStatusBadge extends StatelessWidget {
  const TaskStatusBadge({required this.task, super.key});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    if (task.isCompleted) {
      return const Text(
        'Completed',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2E7D32),
        ),
      );
    }

    final badge = task.reminderBadge();
    if (badge == null) return const SizedBox.shrink();
    return TaskDueBadge(badge: badge);
  }
}
