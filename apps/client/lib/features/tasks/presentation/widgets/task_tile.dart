import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_checkbox.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_status_badge.dart';
import 'package:flutter/material.dart';

/// Compact checklist row — title + optional due badge only.
class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    required this.onToggleComplete,
    required this.onOpen,
    required this.onDuplicate,
    required this.onDelete,
    super.key,
  });

  final TaskModel task;
  final VoidCallback onToggleComplete;
  final VoidCallback onOpen;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  Future<void> _showContextMenu(
    BuildContext context,
    Offset globalPosition,
  ) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final selected = await showMenu<_TaskMenuAction>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      elevation: 4,
      items: const [
        PopupMenuItem(
          value: _TaskMenuAction.rename,
          child: Text('Rename'),
        ),
        PopupMenuItem(
          value: _TaskMenuAction.duplicate,
          child: Text('Duplicate'),
        ),
        PopupMenuItem(
          value: _TaskMenuAction.delete,
          child: Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );

    switch (selected) {
      case _TaskMenuAction.rename:
        onOpen();
      case _TaskMenuAction.duplicate:
        onDuplicate();
      case _TaskMenuAction.delete:
        onDelete();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = task.status();
    final isCompleted = task.isCompleted;
    final dueBadge = isCompleted ? null : task.reminderBadge();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        onSecondaryTapDown: (details) =>
            _showContextMenu(context, details.globalPosition),
        hoverColor: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isCompleted ? 0.55 : 1,
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  TaskCheckbox(
                    value: isCompleted,
                    isOverdue: status == TaskStatus.overdue,
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
                        decorationColor: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (dueBadge != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    TaskDueBadge(badge: dueBadge),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TaskMenuAction { rename, duplicate, delete }
