import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_editor_dialog.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_empty_state.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_list.dart';
import 'package:billing_baba/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight checklist block for the dashboard Action Center.
class ActionCenterTasksSection extends ConsumerWidget {
  const ActionCenterTasksSection({super.key});

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    TaskModel? editTask,
  }) async {
    final result = await showTaskEditorDialog(context, editTask: editTask);
    if (result == null || !context.mounted) return;

    await applyTaskEditorResult(
      result: result,
      notifier: ref.read(tasksProvider.notifier),
      editTask: editTask,
    );
  }

  Future<void> _toggleComplete(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) async {
    final previous = await ref
        .read(tasksProvider.notifier)
        .toggleComplete(task.id);
    if (previous == null || !context.mounted) return;

    final wasCompleting = !previous.isCompleted;
    if (!wasCompleting) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reminder completed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            unawaited(ref.read(tasksProvider.notifier).restore(previous));
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCompleted(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete completed?'),
        content: const Text(
          'Permanently remove all completed reminders. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(tasksProvider.notifier).clearCompleted();
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final tasks = TaskSort.filterAndSort(
      tasksAsync.value ?? const <TaskModel>[],
      filter: TaskFilter.all,
    );
    final showEmpty = tasksAsync.hasValue && tasks.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Tasks",
                    style: DashboardTypography.cardTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Personal reminders',
                    style: DashboardTypography.metadata,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => unawaited(_openEditor(context, ref)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '+ Add',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuButton<_OverflowAction>(
              tooltip: 'More',
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textSecondary,
              ),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              onSelected: (action) async {
                switch (action) {
                  case _OverflowAction.clearCompleted:
                    await ref.read(tasksProvider.notifier).clearCompleted();
                  case _OverflowAction.deleteCompleted:
                    await _confirmDeleteCompleted(context, ref);
                  case _OverflowAction.viewAll:
                    _showComingSoon(context, 'View all tasks');
                  case _OverflowAction.settings:
                    _showComingSoon(context, 'Task settings');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _OverflowAction.clearCompleted,
                  child: Text('Clear Completed'),
                ),
                PopupMenuItem(
                  value: _OverflowAction.deleteCompleted,
                  child: Text('Delete Completed'),
                ),
                // PopupMenuItem(
                //   value: _OverflowAction.viewAll,
                //   child: Text('View All Tasks'),
                // ),
                // PopupMenuItem(
                //   value: _OverflowAction.settings,
                //   child: Text('Settings'),
                // ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(child: AppLoader()),
            error: (error, _) => Center(
              child: Text(
                'Could not load reminders',
                style: DashboardTypography.metadata.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            data: (_) {
              if (showEmpty) {
                return TaskEmptyState(
                  onAdd: () => unawaited(_openEditor(context, ref)),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TaskList(
                      tasks: tasks,
                      onToggleComplete: (task) =>
                          unawaited(_toggleComplete(context, ref, task)),
                      onOpen: (task) => unawaited(
                        _openEditor(context, ref, editTask: task),
                      ),
                      onDuplicate: (task) => unawaited(
                        ref.read(tasksProvider.notifier).duplicate(task.id),
                      ),
                      onDelete: (task) => unawaited(
                        ref.read(tasksProvider.notifier).delete(task.id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => unawaited(_openEditor(context, ref)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '+ Add reminder',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

enum _OverflowAction {
  clearCompleted,
  deleteCompleted,
  viewAll,
  settings,
}
