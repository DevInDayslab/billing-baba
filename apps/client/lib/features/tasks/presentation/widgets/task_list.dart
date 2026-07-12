import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:billing_baba/features/tasks/presentation/widgets/task_tile.dart';
import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  const TaskList({
    required this.tasks,
    required this.onToggleComplete,
    required this.onOpen,
    required this.onDuplicate,
    required this.onDelete,
    super.key,
  });

  final List<TaskModel> tasks;
  final void Function(TaskModel task) onToggleComplete;
  final void Function(TaskModel task) onOpen;
  final void Function(TaskModel task) onDuplicate;
  final void Function(TaskModel task) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: TaskTile(
            key: ValueKey(task.id),
            task: task,
            onToggleComplete: () => onToggleComplete(task),
            onOpen: () => onOpen(task),
            onDuplicate: () => onDuplicate(task),
            onDelete: () => onDelete(task),
          ),
        );
      },
    );
  }
}
