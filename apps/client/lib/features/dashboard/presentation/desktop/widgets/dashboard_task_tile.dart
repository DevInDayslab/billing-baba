import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Compact task row for the dashboard to-do widget.
class DashboardTaskTile extends StatelessWidget {
  const DashboardTaskTile({
    required this.task,
    required this.onToggleComplete,
    required this.onOpen,
    super.key,
  });

  final TaskModel task;
  final VoidCallback onToggleComplete;
  final VoidCallback onOpen;

  static final _timeFormat = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final category = TaskCategoryResolver.resolve(task);
    final status = _TaskRowStatus.fromTask(task);
    final dateLabel = _dateTimeLabel(task);
    final rowColor = category.rowBackgroundColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        hoverColor: rowColor.withValues(alpha: 0.85),
        splashColor: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isCompleted
                ? rowColor.withValues(alpha: 0.35)
                : rowColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: TaskCheckbox(
                  value: isCompleted,
                  isOverdue: task.status() == TaskStatus.overdue,
                  onChanged: (_) => onToggleComplete(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CategoryIcon(category: category),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isCompleted
                            ? AppColors.textSecondary.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: status.color,
                    ),
                  ),
                  if (dateLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _dateTimeLabel(TaskModel task) {
    if (task.isCompleted) {
      final completed = task.completedAt;
      if (completed == null) return null;
      return _relativeDate(completed);
    }

    final reminder = task.reminderAt;
    if (reminder == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay = DateTime(reminder.year, reminder.month, reminder.day);

    if (reminderDay == today) {
      return _timeFormat.format(reminder);
    }
    if (reminderDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    if (reminderDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    }
    return DateFormat('dd MMM').format(reminder);
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final value = DateTime(date.year, date.month, date.day);

    if (value == today) return _timeFormat.format(date);
    if (value == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('dd MMM').format(date);
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});

  final TaskCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: category.iconBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        category.icon,
        size: 14,
        color: category.iconColor,
      ),
    );
  }
}

class _TaskRowStatus {
  const _TaskRowStatus({required this.label, required this.color});

  factory _TaskRowStatus.fromTask(TaskModel task) {
    if (task.isCompleted) {
      return const _TaskRowStatus(
        label: 'Completed',
        color: Color(0xFF2E7D32),
      );
    }

    final badge = task.reminderBadge();
    return switch (badge) {
      TaskReminderBadge.overdue => const _TaskRowStatus(
        label: 'Overdue',
        color: AppColors.error,
      ),
      TaskReminderBadge.today => const _TaskRowStatus(
        label: 'Today',
        color: Color(0xFFF57F17),
      ),
      TaskReminderBadge.tomorrow => const _TaskRowStatus(
        label: 'Tomorrow',
        color: Color(0xFF1565C0),
      ),
      null => const _TaskRowStatus(
        label: 'Pending',
        color: AppColors.textSecondary,
      ),
    };
  }

  final String label;
  final Color color;
}
