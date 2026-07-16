import 'dart:async';

import 'package:billing_baba/core/layout/dashboard_layout.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_expanded_panel.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_task_tile.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_editor_dialog.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_empty_state.dart';
import 'package:billing_baba/features/tasks/providers/tasks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardTodoFilter { today, all }

class DashboardTodoWidget extends ConsumerStatefulWidget {
  const DashboardTodoWidget({super.key});

  @override
  ConsumerState<DashboardTodoWidget> createState() =>
      _DashboardTodoWidgetState();
}

class _DashboardTodoWidgetState extends ConsumerState<DashboardTodoWidget> {
  DashboardTodoFilter _filter = DashboardTodoFilter.today;

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
    final sorted = TaskSort.filterAndSort(
      tasks,
      filter: TaskFilter.all,
    );

    if (_filter == DashboardTodoFilter.all) return sorted;

    final today = DateTime.now();
    return sorted
        .where((task) {
          final reminder = task.reminderAt;
          if (reminder == null) return !task.isCompleted;
          return _isSameDay(reminder, today) || task.status(now: today) == TaskStatus.overdue;
        })
        .toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _openExpanded() {
    unawaited(
      showDashboardExpandedPanel(
        context,
        initialFilter: _filter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = DashboardLayoutScope.of(context);
    final tasksAsync = ref.watch(tasksProvider);
    final tasks = _filteredTasks(tasksAsync.value ?? const []);
    final showEmpty = tasksAsync.hasValue && tasks.isEmpty;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'To-Do list',
                style: DashboardTypography.cardTitle,
              ),
            ),
            _TodoFilterButton(
              filter: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            IconButton(
              tooltip: 'Add task',
              onPressed: () => unawaited(_openEditor()),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              color: AppColors.primary,
              padding: const EdgeInsets.all(AppSpacing.xs),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: 'Expand',
              onPressed: _openExpanded,
              icon: const Icon(Icons.open_in_full, size: 16),
              color: AppColors.textSecondary,
              padding: const EdgeInsets.all(AppSpacing.xs),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${tasks.length} Task${tasks.length == 1 ? '' : 's'}',
          style: DashboardTypography.metadata,
        ),
        SizedBox(height: metrics.gap * 0.5),
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
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

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return DashboardTaskTile(
                    key: ValueKey(task.id),
                    task: task,
                    onToggleComplete: () => unawaited(_toggleComplete(task)),
                    onOpen: () => unawaited(_openEditor(editTask: task)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );

    return DashboardMetricCard(
      padding: metrics.cardPadding,
      child: content,
    );
  }
}

class _TodoFilterButton extends StatelessWidget {
  const _TodoFilterButton({
    required this.filter,
    required this.onChanged,
  });

  final DashboardTodoFilter filter;
  final ValueChanged<DashboardTodoFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => onChanged(DashboardTodoFilter.today),
          child: const Text('Today'),
        ),
        MenuItemButton(
          onPressed: () => onChanged(DashboardTodoFilter.all),
          child: const Text('All'),
        ),
      ],
      builder: (context, controller, child) {
        return Material(
          color: AppColors.background,
          borderRadius: AppRadius.lgBorder,
          child: InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            borderRadius: AppRadius.lgBorder,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.xs + 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter == DashboardTodoFilter.today ? 'Today' : 'All',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
