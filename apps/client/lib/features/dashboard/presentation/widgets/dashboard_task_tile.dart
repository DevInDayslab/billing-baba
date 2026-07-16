import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Compact colored task row for the dashboard to-do widget.
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

  static final _timeFormat = DateFormat('HH:mm');

  static const _backgrounds = <Color>[
    Color(0xFFFFE4EC),
    Color(0xFFFFF3CD),
    Color(0xFFD4EDDA),
    Color(0xFFD1ECF1),
    Color(0xFFE2D9F3),
  ];

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final background = _backgrounds[task.id.hashCode.abs() % _backgrounds.length];
    final timeLabel = task.reminderAt != null
        ? _timeFormat.format(task.reminderAt!)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: background.withValues(alpha: isCompleted ? 0.45 : 0.9),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              TaskCheckbox(
                value: isCompleted,
                isOverdue: task.status() == TaskStatus.overdue,
                onChanged: (_) => onToggleComplete(),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isCompleted
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (timeLabel != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
