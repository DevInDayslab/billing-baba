import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_task_tile.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_todo_filters.dart';
import 'package:billing_baba/features/dashboard/presentation/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_editor_dialog.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_empty_state.dart';
import 'package:billing_baba/features/tasks/providers/tasks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showDashboardExpandedPanel(
  BuildContext context, {
  DashboardTodoScopeFilter initialScope = DashboardTodoScopeFilter.today,
  DashboardTodoStatusChip initialStatusChip = DashboardTodoStatusChip.pending,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: DashboardExpandedPanel(
          initialScope: initialScope,
          initialStatusChip: initialStatusChip,
        ),
      ),
    ),
  );
}

class DashboardExpandedPanel extends ConsumerStatefulWidget {
  const DashboardExpandedPanel({
    this.initialScope = DashboardTodoScopeFilter.today,
    this.initialStatusChip = DashboardTodoStatusChip.pending,
    super.key,
  });

  final DashboardTodoScopeFilter initialScope;
  final DashboardTodoStatusChip initialStatusChip;

  @override
  ConsumerState<DashboardExpandedPanel> createState() =>
      _DashboardExpandedPanelState();
}

class _DashboardExpandedPanelState extends ConsumerState<DashboardExpandedPanel> {
  late DashboardTodoScopeFilter _scopeFilter;
  late DashboardTodoStatusChip _statusChip;

  @override
  void initState() {
    super.initState();
    _scopeFilter = widget.initialScope;
    _statusChip = widget.initialStatusChip;
  }

  Future<void> _openEditor({TaskModel? editTask}) async {
    final result = await showTaskEditorDialog(
      context,
      editTask: editTask,
    );
    if (result == null || !mounted) return;

    await applyTaskEditorResult(
      result: result,
      notifier: ref.read(tasksProvider.notifier),
      editTask: editTask,
    );
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

  Widget _emptyStateForChip() {
    if (_statusChip == DashboardTodoStatusChip.pending) {
      return TaskEmptyState(
        onAdd: () => unawaited(_openEditor()),
        size: 80,
      );
    }

    final message = switch (_statusChip) {
      DashboardTodoStatusChip.all => 'No tasks yet',
      DashboardTodoStatusChip.today => 'Nothing due today',
      DashboardTodoStatusChip.overdue => 'No overdue tasks',
      DashboardTodoStatusChip.pending => "You're all caught up!",
    };

    return Center(
      child: Text(
        message,
        style: DashboardTypography.metadata,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final allTasks = tasksAsync.value ?? const <TaskModel>[];
    final scopedTasks = DashboardTodoFilterLogic.applyScope(
      allTasks,
      scope: _scopeFilter,
    );
    final tasks = DashboardTodoFilterLogic.applyStatusChip(
      scopedTasks,
      chip: _statusChip,
    );
    final summary = DashboardTodoFilterLogic.summaryCounts(allTasks);
    final overdueCount = DashboardTodoFilterLogic.overdueBadgeCount(allTasks);
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
              DashboardTodoScopeButton(
                scope: _scopeFilter,
                onChanged: (value) => setState(() => _scopeFilter = value),
              ),
              TextButton.icon(
                onPressed: () => unawaited(_openEditor()),
                icon: const Icon(
                  color: AppColors.primary,
                  Icons.add_circle_outline,
                  size: 20,
                ),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DashboardTodoSummaryLine(
            pending: summary.pending,
            overdue: summary.overdue,
          ),
          const SizedBox(height: AppSpacing.md),
          DashboardTodoStatusChips(
            selected: _statusChip,
            overdueCount: overdueCount,
            onChanged: (value) => setState(() => _statusChip = value),
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
                if (showEmpty) return _emptyStateForChip();

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
      ),
    );
  }
}
