import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_todo_widget.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_editor_dialog.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_empty_state.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_list.dart';
import 'package:billing_baba/features/tasks/providers/tasks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showDashboardExpandedPanel(
  BuildContext context, {
  DashboardTodoFilter initialFilter = DashboardTodoFilter.today,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: DashboardExpandedPanel(initialFilter: initialFilter),
      ),
    ),
  );
}

class DashboardExpandedPanel extends ConsumerStatefulWidget {
  const DashboardExpandedPanel({
    this.initialFilter = DashboardTodoFilter.today,
    super.key,
  });

  final DashboardTodoFilter initialFilter;

  @override
  ConsumerState<DashboardExpandedPanel> createState() =>
      _DashboardExpandedPanelState();
}

class _DashboardExpandedPanelState extends ConsumerState<DashboardExpandedPanel> {
  late DashboardTodoFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  Future<void> _openEditor({TaskModel? editTask}) async {
    final result = await showTaskEditorDialog(
      context,
      editTask: editTask,
    );
    if (result == null || !mounted) return;

    final notifier = ref.read(tasksProvider.notifier);
    if (editTask != null) {
      await notifier.updateTask(
        editTask.copyWith(
          title: result.title,
          description: result.description,
          clearDescription: result.description == null,
          reminderAt: result.reminderAt,
          clearReminderAt: result.reminderAt == null,
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      await notifier.add(
        title: result.title,
        description: result.description,
        reminderAt: result.reminderAt,
      );
    }
  }

  Future<void> _toggleComplete(TaskModel task) async {
    final previous = await ref.read(tasksProvider.notifier).toggleComplete(
      task.id,
    );
    if (previous == null || !mounted) return;

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

  List<TaskModel> _filteredTasks(List<TaskModel> tasks) {
    final sorted = TaskSort.filterAndSort(tasks, filter: TaskFilter.all);
    if (_filter == DashboardTodoFilter.all) return sorted;

    final today = DateTime.now();
    return sorted
        .where((task) {
          final reminder = task.reminderAt;
          if (reminder == null) return !task.isCompleted;
          return _isSameDay(reminder, today) ||
              task.status(now: today) == TaskStatus.overdue;
        })
        .toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final tasks = _filteredTasks(tasksAsync.value ?? const []);
    final showEmpty = tasksAsync.hasValue && tasks.isEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'To-Do list',
                  style: DashboardTypography.pageTitle,
                ),
              ),
              DropdownButton<DashboardTodoFilter>(
                value: _filter,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: DashboardTodoFilter.today,
                    child: Text('Today'),
                  ),
                  DropdownMenuItem(
                    value: DashboardTodoFilter.all,
                    child: Text('All'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _filter = value);
                },
              ),
              TextButton.icon(
                onPressed: () => unawaited(_openEditor()),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
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
                    onAdd: () => unawaited(_openEditor()),
                  );
                }

                return TaskList(
                  tasks: tasks,
                  onToggleComplete: (task) => unawaited(_toggleComplete(task)),
                  onOpen: (task) => unawaited(_openEditor(editTask: task)),
                  onDuplicate: (task) => unawaited(
                    ref.read(tasksProvider.notifier).duplicate(task.id),
                  ),
                  onDelete: (task) => unawaited(
                    ref.read(tasksProvider.notifier).delete(task.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
