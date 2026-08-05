import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_task_tile.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_todo_filters.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_editor_dialog.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Alerts tab — mobile port of the desktop TODO widget.
class MobileHomeAlertsTab extends ConsumerStatefulWidget {
  const MobileHomeAlertsTab({super.key});

  @override
  ConsumerState<MobileHomeAlertsTab> createState() =>
      _MobileHomeAlertsTabState();
}

class _MobileHomeAlertsTabState extends ConsumerState<MobileHomeAlertsTab>
    with AutomaticKeepAliveClientMixin {
  DashboardTodoStatusChip _statusChip = DashboardTodoStatusChip.pending;

  @override
  bool get wantKeepAlive => true;

  Future<void> _openEditor({TaskModel? editTask}) async {
    final result = await showTaskEditorDialog(context, editTask: editTask);
    if (result == null || !mounted) return;
    await applyTaskEditorResult(
      result: result,
      notifier: ref.read(tasksProvider.notifier),
      editTask: editTask,
    );
  }

  Future<void> _toggleComplete(TaskModel task) async {
    final previous = await ref
        .read(tasksProvider.notifier)
        .toggleComplete(
          task.id,
        );
    if (previous == null || !mounted) return;
    if (previous.isCompleted) return;

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tasksAsync = ref.watch(tasksProvider);
    final allTasks = tasksAsync.value ?? const <TaskModel>[];
    final scopedTasks = DashboardTodoFilterLogic.applyScope(
      allTasks,
      scope: DashboardTodoScopeFilter.all,
    );
    final tasks = DashboardTodoFilterLogic.applyStatusChip(
      scopedTasks,
      chip: _statusChip,
    );
    final summary = DashboardTodoFilterLogic.summaryCounts(allTasks);
    final overdueCount = DashboardTodoFilterLogic.overdueBadgeCount(allTasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Daily Alerts',
                  style: AppTypography.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => unawaited(_openEditor()),
                icon: const Icon(Icons.add_rounded),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: DashboardTodoSummaryLine(
            pending: summary.pending,
            overdue: summary.overdue,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: DashboardTodoStatusChips(
            selected: _statusChip,
            overdueCount: overdueCount,
            onChanged: (value) => setState(() => _statusChip = value),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(tasksProvider),
                child: const Text('Retry'),
              ),
            ),
            data: (_) {
              if (tasks.isEmpty) {
                if (_statusChip == DashboardTodoStatusChip.pending) {
                  return TaskEmptyState(
                    onAdd: () => unawaited(_openEditor()),
                  );
                }
                return Center(
                  child: Text(
                    switch (_statusChip) {
                      DashboardTodoStatusChip.all => 'No tasks yet',
                      DashboardTodoStatusChip.today => 'Nothing due today',
                      DashboardTodoStatusChip.overdue => 'No overdue tasks',
                      DashboardTodoStatusChip.pending =>
                        "You're all caught up!",
                    },
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                itemCount: tasks.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Material(
                    color: AppColors.surface,
                    borderRadius: AppRadius.cardBorder,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.cardBorder,
                        boxShadow: AppShadows.subtle,
                      ),
                      child: DashboardTaskTile(
                        key: ValueKey(task.id),
                        task: task,
                        onToggleComplete: () =>
                            unawaited(_toggleComplete(task)),
                        onOpen: () => unawaited(_openEditor(editTask: task)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Badge count for the Alerts tab (pending + overdue).
int mobileHomeAlertsBadgeCount(List<TaskModel> tasks) {
  final summary = DashboardTodoFilterLogic.summaryCounts(tasks);
  return summary.pending + summary.overdue;
}
