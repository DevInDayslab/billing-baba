import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_todo_filters.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_todo_status_tabs.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_todo_task_tile.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_editor_dialog.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Todo tab — mobile home reminders and tasks.
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
    final primary = Theme.of(context).colorScheme.primary;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Todo',
                      style: AppTypography.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: AppTypography.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(
                            text: '${summary.pending} Pending',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: '  •  '),
                          TextSpan(
                            text: '${summary.overdue} Overdue',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: primary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => unawaited(_openEditor()),
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        MobileHomeTodoStatusTabs(
          selected: _statusChip,
          overdueCount: overdueCount,
          onChanged: (value) => setState(() => _statusChip = value),
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
                    style: AppTypography.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  MobileBottomNavigation.contentBottomPadding(context),
                ),
                itemCount: tasks.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return MobileHomeTodoTaskTile(
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
  }
}

/// Badge count for the Todo tab (pending + overdue).
int mobileHomeAlertsBadgeCount(List<TaskModel> tasks) {
  final summary = DashboardTodoFilterLogic.summaryCounts(tasks);
  return summary.pending + summary.overdue;
}
