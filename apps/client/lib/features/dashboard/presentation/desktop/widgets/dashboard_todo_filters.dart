import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/desktop/widgets/dashboard_typography.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:flutter/material.dart';

/// **Period** filter (header dropdown) — limits which tasks are in scope by date.
///
/// - [today]: due today, overdue, or open tasks without a due date.
/// - [all]: every task regardless of due date.
enum DashboardTodoScopeFilter { today, all }

/// **Status** filter (pills) — narrows the scoped list by completion / due state.
///
/// - [all]: every task in the current period (including completed).
/// - [today]: non-completed tasks due today.
/// - [overdue]: non-completed overdue tasks.
/// - [pending]: non-completed tasks (active work).
enum DashboardTodoStatusChip { all, today, overdue, pending }

abstract final class DashboardTodoFilterLogic {
  static List<TaskModel> applyScope(
    List<TaskModel> tasks, {
    required DashboardTodoScopeFilter scope,
    DateTime? now,
  }) {
    final sorted = TaskSort.filterAndSort(tasks, filter: TaskFilter.all, now: now);
    if (scope == DashboardTodoScopeFilter.all) return sorted;

    final clock = now ?? DateTime.now();
    return sorted
        .where((task) {
          final reminder = task.reminderAt;
          if (reminder == null) return !task.isCompleted;
          return _isSameDay(reminder, clock) ||
              task.status(now: clock) == TaskStatus.overdue;
        })
        .toList();
  }

  static List<TaskModel> applyStatusChip(
    List<TaskModel> scoped, {
    required DashboardTodoStatusChip chip,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();

    return scoped.where((task) {
      switch (chip) {
        case DashboardTodoStatusChip.all:
          return true;
        case DashboardTodoStatusChip.pending:
          return !task.isCompleted;
        case DashboardTodoStatusChip.today:
          if (task.isCompleted) return false;
          return task.reminderBadge(now: clock) == TaskReminderBadge.today;
        case DashboardTodoStatusChip.overdue:
          return !task.isCompleted &&
              task.status(now: clock) == TaskStatus.overdue;
      }
    }).toList();
  }

  static ({int pending, int overdue}) summaryCounts(
    List<TaskModel> allTasks, {
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final pending = allTasks.where((task) => !task.isCompleted).length;
    final overdue = allTasks
        .where(
          (task) =>
              !task.isCompleted &&
              task.status(now: clock) == TaskStatus.overdue,
        )
        .length;
    return (pending: pending, overdue: overdue);
  }

  static int overdueBadgeCount(List<TaskModel> allTasks, {DateTime? now}) {
    final clock = now ?? DateTime.now();
    return allTasks
        .where(
          (task) =>
              !task.isCompleted &&
              task.status(now: clock) == TaskStatus.overdue,
        )
        .length;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class DashboardTodoSummaryLine extends StatelessWidget {
  const DashboardTodoSummaryLine({
    required this.pending,
    required this.overdue,
    super.key,
  });

  final int pending;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DashboardTypography.metadata,
        children: [
          TextSpan(text: '$pending Pending'),
          const TextSpan(text: '  •  '),
          TextSpan(
            text: '$overdue Overdue',
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardTodoScopeButton extends StatelessWidget {
  const DashboardTodoScopeButton({
    required this.scope,
    required this.onChanged,
    super.key,
  });

  final DashboardTodoScopeFilter scope;
  final ValueChanged<DashboardTodoScopeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Period — limit tasks by date range',
      child: MenuAnchor(
        menuChildren: [
          MenuItemButton(
            onPressed: () => onChanged(DashboardTodoScopeFilter.today),
            child: const Text('Today'),
          ),
          MenuItemButton(
            onPressed: () => onChanged(DashboardTodoScopeFilter.all),
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
                      scope == DashboardTodoScopeFilter.today ? 'Today' : 'All',
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
      ),
    );
  }
}

class DashboardTodoStatusChips extends StatelessWidget {
  const DashboardTodoStatusChips({
    required this.selected,
    required this.overdueCount,
    required this.onChanged,
    super.key,
  });

  final DashboardTodoStatusChip selected;
  final int overdueCount;
  final ValueChanged<DashboardTodoStatusChip> onChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Status — filter tasks by completion or due state',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StatusChip(
              label: 'All',
              isSelected: selected == DashboardTodoStatusChip.all,
              onTap: () => onChanged(DashboardTodoStatusChip.all),
            ),
            const SizedBox(width: AppSpacing.xs),
            _StatusChip(
              label: 'Today',
              isSelected: selected == DashboardTodoStatusChip.today,
              onTap: () => onChanged(DashboardTodoStatusChip.today),
            ),
            const SizedBox(width: AppSpacing.xs),
            _StatusChip(
              label: 'Overdue',
              isSelected: selected == DashboardTodoStatusChip.overdue,
              badgeCount: overdueCount > 0 ? overdueCount : null,
              onTap: () => onChanged(DashboardTodoStatusChip.overdue),
            ),
            const SizedBox(width: AppSpacing.xs),
            _StatusChip(
              label: 'Pending',
              isSelected: selected == DashboardTodoStatusChip.pending,
              onTap: () => onChanged(DashboardTodoStatusChip.pending),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFE3F2FD) : AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              if (badgeCount != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
