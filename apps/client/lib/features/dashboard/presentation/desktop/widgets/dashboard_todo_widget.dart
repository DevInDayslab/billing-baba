import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_expanded_panel.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_metric_card.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_task_tile.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_todo_filters.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_editor_dialog.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_empty_state.dart';
import 'package:billing_baba/shared/layout/dashboard_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class DashboardTodoWidget extends ConsumerStatefulWidget {
  const DashboardTodoWidget({super.key});

  @override
  ConsumerState<DashboardTodoWidget> createState() =>
      _DashboardTodoWidgetState();
}

class _DashboardTodoWidgetState extends ConsumerState<DashboardTodoWidget> {
  DashboardTodoScopeFilter _scopeFilter = DashboardTodoScopeFilter.today;
  DashboardTodoStatusChip _statusChip = DashboardTodoStatusChip.pending;

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
    final previous = await ref
        .read(tasksProvider.notifier)
        .toggleComplete(
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

  void _openExpanded() {
    unawaited(
      showDashboardExpandedPanel(
        context,
        initialScope: _scopeFilter,
        initialStatusChip: _statusChip,
      ),
    );
  }

  Widget _emptyStateForChip() {
    if (_statusChip == DashboardTodoStatusChip.pending) {
      return TaskEmptyState(
        onAdd: () => unawaited(_openEditor()),
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
    final metrics = DashboardLayoutScope.of(context);
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

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Flexible(
                    child: Text(
                      'To-Do',
                      style: DashboardTypography.cardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _AddReminderButton(
                    onPressed: () => unawaited(_openEditor()),
                  ),
                ],
              ),
            ),
            DashboardTodoScopeButton(
              scope: _scopeFilter,
              onChanged: (value) => setState(() => _scopeFilter = value),
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
        DashboardTodoSummaryLine(
          pending: summary.pending,
          overdue: summary.overdue,
        ),
        SizedBox(height: metrics.gap * 1.5),
        DashboardTodoStatusChips(
          selected: _statusChip,
          overdueCount: overdueCount,
          onChanged: (value) => setState(() => _statusChip = value),
        ),
        SizedBox(height: metrics.gap * 0.5),
        Expanded(
          child: tasksAsync.when(
            loading: () => const _TodoLoadingSkeleton(),
            error: (_, _) => _TodoErrorState(
              onRetry: () => ref.invalidate(tasksProvider),
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
        if (!showEmpty && tasksAsync.hasValue) ...[
          const SizedBox(height: AppSpacing.xs),
          Align(
            child: TextButton(
              onPressed: _openExpanded,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all tasks',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ),
        ],
      ],
    );

    return DashboardMetricCard(
      padding: metrics.cardPadding,
      child: content,
    );
  }
}

class _AddReminderButton extends StatelessWidget {
  const _AddReminderButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          Icons.add_circle_outline,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _TodoLoadingSkeleton extends StatelessWidget {
  const _TodoLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TodoErrorState extends StatelessWidget {
  const _TodoErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 32,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
