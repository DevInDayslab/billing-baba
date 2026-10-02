import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_todo_filters.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_controller.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_todo_status_tabs.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/home/mobile_home_todo_task_tile.dart';
import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_editor_dialog.dart';
import 'package:billing_baba/features/tasks/presentation/desktop/widgets/task_empty_state.dart';
import 'package:billing_baba/features/tasks/presentation/task_undo_redo_snackbar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Alerts / daily-todo tab — mobile home reminders and tasks.
///
/// [scrollChrome] (search + home tabs) scrolls with content, like Items.
class MobileHomeAlertsTab extends ConsumerStatefulWidget {
  const MobileHomeAlertsTab({
    required this.scrollChrome,
    super.key,
  });

  final Widget scrollChrome;

  @override
  ConsumerState<MobileHomeAlertsTab> createState() =>
      _MobileHomeAlertsTabState();
}

class _MobileHomeAlertsTabState extends ConsumerState<MobileHomeAlertsTab>
    with AutomaticKeepAliveClientMixin {
  DashboardTodoStatusChip _statusChip = DashboardTodoStatusChip.all;

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

  static final _reminderDateFormat = DateFormat('dd MMM yyyy h:mm a');

  bool _taskMatchesSearch(TaskModel task, String query) {
    if (query.isEmpty) return true;
    final category = TaskCategoryResolver.resolve(task).label;
    final reminderText = task.reminderAt != null
        ? _reminderDateFormat.format(task.reminderAt!)
        : '';
    final haystack = '${task.title} $category $reminderText'.toLowerCase();
    return haystack.contains(query);
  }

  Future<void> _refreshTasks() async {
    ref.invalidate(tasksProvider);
    await ref.read(tasksProvider.future);
  }

  Future<void> _toggleComplete(TaskModel task) async {
    final previous = await ref
        .read(tasksProvider.notifier)
        .toggleComplete(
          task.id,
        );
    if (previous == null || !mounted) return;
    if (previous.isCompleted) return;

    showTaskCompletionUndoRedoSnackBar(
      context: context,
      ref: ref,
      snapshotBeforeComplete: previous,
    );
  }

  Widget _sectionHeader({
    required Color primary,
    required int pendingCount,
    required int overdueCount,
  }) {
    return Padding(
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
                        text: '$pendingCount Pending',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '  •  '),
                      TextSpan(
                        text: '$overdueCount Overdue',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primary = Theme.of(context).colorScheme.primary;
    final homeState = ref.watch(mobileHomeControllerProvider);
    final searchQuery = homeState.searchQuery.trim().toLowerCase();
    final tasksAsync = ref.watch(tasksProvider);
    final allTasks = tasksAsync.value ?? const <TaskModel>[];
    final tasks = DashboardTodoFilterLogic.applyStatusFilters(
      allTasks,
      scope: DashboardTodoScopeFilter.all,
      chip: _statusChip,
    ).where((task) => _taskMatchesSearch(task, searchQuery)).toList();
    final summary = DashboardTodoFilterLogic.summaryCounts(allTasks);
    final overdueCount = DashboardTodoFilterLogic.overdueBadgeCount(allTasks);

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: widget.scrollChrome),
          SliverToBoxAdapter(
            child: _sectionHeader(
              primary: primary,
              pendingCount: summary.pending,
              overdueCount: summary.overdue,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(
            child: MobileHomeTodoStatusTabs(
              selected: _statusChip,
              overdueCount: overdueCount,
              onChanged: (value) => setState(() => _statusChip = value),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          ...tasksAsync.when(
            loading: () => [
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (_, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(tasksProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ],
            data: (_) {
              if (tasks.isEmpty) {
                if (_statusChip == DashboardTodoStatusChip.pending &&
                    searchQuery.isEmpty) {
                  return [
                    SliverToBoxAdapter(
                      child: TaskEmptyState(
                        onAdd: () => unawaited(_openEditor()),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MobileBottomNavigation.contentBottomPadding(
                          context,
                        ),
                      ),
                    ),
                  ];
                }
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        searchQuery.isNotEmpty
                            ? 'No tasks match your search'
                            : switch (_statusChip) {
                                DashboardTodoStatusChip.all => 'No tasks yet',
                                DashboardTodoStatusChip.today =>
                                  'Nothing due today',
                                DashboardTodoStatusChip.overdue =>
                                  'No overdue tasks',
                                DashboardTodoStatusChip.pending =>
                                  "You're all caught up!",
                                DashboardTodoStatusChip.completed =>
                                  'No completed tasks yet',
                              },
                        style: AppTypography.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ];
              }

              return [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    MobileBottomNavigation.contentBottomPadding(context),
                  ),
                  sliver: SliverList.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return MobileHomeTodoTaskTile(
                        key: ValueKey(task.id),
                        task: task,
                        onToggleComplete: () =>
                            unawaited(_toggleComplete(task)),
                        onOpen: () => unawaited(_openEditor(editTask: task)),
                      );
                    },
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

/// Badge count for the Todo tab (pending + overdue).
int mobileHomeAlertsBadgeCount(List<TaskModel> tasks) {
  final summary = DashboardTodoFilterLogic.summaryCounts(tasks);
  return summary.pending + summary.overdue;
}
