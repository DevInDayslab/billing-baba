import 'package:billing_baba/features/tasks/application/tasks_provider.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_completion_undo_redo_provider.g.dart';

class TaskCompletionUndoRedoState {
  const TaskCompletionUndoRedoState({
    this.undoSnapshot,
    this.redoTaskId,
  });

  final TaskModel? undoSnapshot;
  final String? redoTaskId;

  bool get canUndo => undoSnapshot != null;
  bool get canRedo => redoTaskId != null;
}

/// Last task completion undo/redo (Google Sheets–style, single step).
@Riverpod(keepAlive: true)
class TaskCompletionUndoRedo extends _$TaskCompletionUndoRedo {
  @override
  TaskCompletionUndoRedoState build() => const TaskCompletionUndoRedoState();

  void recordCompletion(TaskModel snapshotBeforeComplete) {
    state = TaskCompletionUndoRedoState(
      undoSnapshot: snapshotBeforeComplete,
      redoTaskId: null,
    );
  }

  /// Restores the task; returns the snapshot that was undone (for feedback).
  Future<TaskModel?> undo(Tasks tasksNotifier) async {
    final snapshot = state.undoSnapshot;
    if (snapshot == null) return null;

    await tasksNotifier.restore(snapshot);
    state = TaskCompletionUndoRedoState(
      undoSnapshot: null,
      redoTaskId: snapshot.id,
    );
    return snapshot;
  }

  /// Re-completes after undo; returns pre-toggle snapshot when redo applied.
  Future<TaskModel?> redo(Tasks tasksNotifier) async {
    final taskId = state.redoTaskId;
    if (taskId == null) return null;

    final previous = await tasksNotifier.toggleComplete(taskId);
    if (previous == null) return null;

    if (!previous.isCompleted) {
      state = TaskCompletionUndoRedoState(
        undoSnapshot: previous,
        redoTaskId: null,
      );
    } else {
      state = const TaskCompletionUndoRedoState();
    }
    return previous;
  }

  void clear() {
    state = const TaskCompletionUndoRedoState();
  }
}
