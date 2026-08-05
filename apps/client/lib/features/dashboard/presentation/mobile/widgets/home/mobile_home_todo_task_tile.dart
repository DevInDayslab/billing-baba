import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mobile task row for the home todo tab.
class MobileHomeTodoTaskTile extends StatelessWidget {
  const MobileHomeTodoTaskTile({
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
    final status = _TaskStatus.fromTask(task);
    final timeLabel = _timeLabel(task);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: AppRadius.cardBorder,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardBorder,
            border: Border.all(color: AppColors.chipBorder),
            boxShadow: AppShadows.subtle,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: Row(
            children: [
              TaskCheckbox(
                value: isCompleted,
                isOverdue: task.status() == TaskStatus.overdue,
                onChanged: (_) => onToggleComplete(),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: category.iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 20,
                  color: category.iconColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTypography.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        height: 1.2,
                      ).copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category.label,
                      style: AppTypography.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        height: 1.2,
                      ).copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textSecondary,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: status.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status.label,
                      style: AppTypography.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                        height: 1.1,
                      ),
                    ),
                  ),
                  if (timeLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: AppTypography.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        height: 1.2,
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

  String? _timeLabel(TaskModel task) {
    if (task.isCompleted) {
      final completed = task.completedAt;
      if (completed == null) return null;
      return _timeFormat.format(completed);
    }

    final reminder = task.reminderAt;
    if (reminder == null) return null;
    return _timeFormat.format(reminder);
  }
}

class _TaskStatus {
  const _TaskStatus({
    required this.label,
    required this.color,
    required this.background,
  });

  factory _TaskStatus.fromTask(TaskModel task) {
    if (task.isCompleted) {
      return const _TaskStatus(
        label: 'Done',
        color: Color(0xFF2E7D32),
        background: Color(0xFFE8F5E9),
      );
    }

    final badge = task.reminderBadge();
    return switch (badge) {
      TaskReminderBadge.overdue => const _TaskStatus(
        label: 'Overdue',
        color: AppColors.error,
        background: Color(0xFFFFEBEE),
      ),
      TaskReminderBadge.today => const _TaskStatus(
        label: 'Today',
        color: Color(0xFFF57F17),
        background: Color(0xFFFFF3E0),
      ),
      TaskReminderBadge.tomorrow => const _TaskStatus(
        label: 'Tomorrow',
        color: Color(0xFF1565C0),
        background: Color(0xFFE3F2FD),
      ),
      null => const _TaskStatus(
        label: 'Pending',
        color: AppColors.textSecondary,
        background: Color(0xFFF3F4F6),
      ),
    };
  }

  final String label;
  final Color color;
  final Color background;
}
