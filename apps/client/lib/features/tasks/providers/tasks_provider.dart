import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/tasks/data/task_repository.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tasks_provider.g.dart';

@Riverpod(keepAlive: true)
Future<TaskRepository> taskRepository(Ref ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return TaskRepository(storage);
}

@Riverpod(keepAlive: true)
class TaskFilterState extends _$TaskFilterState {
  @override
  TaskFilter build() => TaskFilter.all;

  TaskFilter get filter => state;

  set filter(TaskFilter value) => state = value;
}

@Riverpod(keepAlive: true)
class Tasks extends _$Tasks {
  String get _businessId => ref.read(currentBusinessProvider)?.id ?? 'default';

  Future<TaskRepository> _repository() =>
      ref.read(taskRepositoryProvider.future);

  @override
  Future<List<TaskModel>> build() async {
    // Rebuild when business changes.
    ref.watch(currentBusinessProvider);
    final repo = await ref.watch(taskRepositoryProvider.future);
    return repo.load(_businessId);
  }

  Future<void> _persist(List<TaskModel> tasks) async {
    final repo = await _repository();
    await repo.save(_businessId, tasks);
  }

  Future<TaskModel?> add({
    required String title,
    String? description,
    DateTime? reminderAt,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return null;

    final repo = await _repository();
    final task = repo.create(
      title: trimmed,
      description: description,
      reminderAt: reminderAt,
    );
    final current = state.value ?? [];
    final next = repo.upsert(current, task);
    state = AsyncData(next);
    await _persist(next);
    return task;
  }

  Future<bool> updateTask(TaskModel task) async {
    final trimmed = task.title.trim();
    if (trimmed.isEmpty) return false;

    final repo = await _repository();
    final updated = task.copyWith(
      title: trimmed,
      updatedAt: DateTime.now(),
    );
    final current = state.value ?? [];
    final next = repo.upsert(current, updated);
    state = AsyncData(next);
    await _persist(next);
    return true;
  }

  Future<void> delete(String id) async {
    final repo = await _repository();
    final current = state.value ?? [];
    final next = repo.remove(current, id);
    state = AsyncData(next);
    await _persist(next);
  }

  /// Returns the previous task snapshot for undo, or null if not found.
  Future<TaskModel?> toggleComplete(String id) async {
    final current = state.value ?? [];
    final index = current.indexWhere((t) => t.id == id);
    if (index == -1) return null;

    final previous = current[index];
    final now = DateTime.now();
    final updated = previous.copyWith(
      isCompleted: !previous.isCompleted,
      completedAt: previous.isCompleted ? null : now,
      clearCompletedAt: previous.isCompleted,
      updatedAt: now,
    );

    final repo = await _repository();
    final next = repo.upsert(current, updated);
    state = AsyncData(next);
    await _persist(next);
    return previous;
  }

  Future<void> restore(TaskModel snapshot) async {
    final repo = await _repository();
    final current = state.value ?? [];
    final next = repo.upsert(current, snapshot);
    state = AsyncData(next);
    await _persist(next);
  }

  /// Returns false when pin cap is reached.
  Future<bool> togglePin(String id) async {
    final repo = await _repository();
    final current = state.value ?? [];
    final next = repo.togglePin(current, id);
    if (next == null) return false;
    state = AsyncData(next);
    await _persist(next);
    return true;
  }

  Future<TaskModel?> duplicate(String id) async {
    final current = state.value ?? [];
    final source = current.where((t) => t.id == id).firstOrNull;
    if (source == null) return null;

    final repo = await _repository();
    final copy = repo.duplicate(source);
    final next = repo.upsert(current, copy);
    state = AsyncData(next);
    await _persist(next);
    return copy;
  }

  Future<void> clearCompleted() async {
    final repo = await _repository();
    final current = state.value ?? [];
    final next = repo.clearCompleted(current);
    state = AsyncData(next);
    await _persist(next);
  }
}

@riverpod
List<TaskModel> filteredTasks(Ref ref) {
  final filter = ref.watch(taskFilterStateProvider);
  final tasks = ref.watch(tasksProvider).value ?? const <TaskModel>[];
  return TaskSort.filterAndSort(tasks, filter: filter);
}
