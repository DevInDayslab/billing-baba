import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/tasks/data/task_repository.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tasks_provider.g.dart';

@Riverpod(keepAlive: true)
class TaskFilterState extends _$TaskFilterState {
  @override
  TaskFilter build() => TaskFilter.all;

  TaskFilter get filter => state;

  set filter(TaskFilter value) => state = value;
}

@Riverpod(keepAlive: true)
class Tasks extends _$Tasks {
  String? get _businessId => ref.read(currentBusinessProvider)?.id;

  Future<TaskRepository> _repository() =>
      ref.read(taskRepositoryProvider.future);

  @override
  Future<List<TaskModel>> build() async {
    ref.watch(currentBusinessProvider);
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) {
      return const [];
    }

    final repo = await ref.watch(taskRepositoryProvider.future);
    return repo.load(businessId);
  }

  Future<void> _reload() async {
    final businessId = _businessId;
    if (businessId == null || businessId.isEmpty) return;
    final repo = await _repository();
    state = AsyncData(await repo.load(businessId));
  }

  Future<TaskModel?> add({
    required String title,
    String? description,
    TaskCategory? category,
    DateTime? reminderAt,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return null;

    final repo = await _repository();
    final task = await repo.persistCreate(
      title: trimmed,
      description: description,
      category: category,
      reminderAt: reminderAt,
    );
    await _reload();
    return task;
  }

  Future<bool> updateTask(TaskModel task) async {
    final trimmed = task.title.trim();
    if (trimmed.isEmpty) return false;

    final repo = await _repository();
    await repo.persistUpdate(task.copyWith(title: trimmed));
    await _reload();
    return true;
  }

  Future<void> delete(String id) async {
    final repo = await _repository();
    await repo.persistDelete(id);
    await _reload();
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
    await repo.persistUpdate(updated);
    await _reload();
    return previous;
  }

  Future<void> restore(TaskModel snapshot) async {
    final repo = await _repository();
    await repo.persistUpdate(snapshot);
    await _reload();
  }

  /// Returns false when pin cap is reached.
  Future<bool> togglePin(String id) async {
    final repo = await _repository();
    final current = state.value ?? [];
    final next = repo.togglePin(current, id);
    if (next == null) return false;

    final updated = next.firstWhere((t) => t.id == id);
    await repo.persistUpdate(updated);
    await _reload();
    return true;
  }

  Future<TaskModel?> duplicate(String id) async {
    final current = state.value ?? [];
    final source = current.where((t) => t.id == id).firstOrNull;
    if (source == null) return null;

    final repo = await _repository();
    final created = await repo.persistDuplicate(source);
    await _reload();
    return created;
  }

  Future<void> clearCompleted() async {
    final repo = await _repository();
    final current = state.value ?? [];
    for (final task in current.where((t) => t.isCompleted)) {
      await repo.persistDelete(task.id);
    }
    await _reload();
  }

  /// Seeds provider state after a business switch without awaiting [.future].
  void replaceWith(List<TaskModel> tasks) {
    state = AsyncData(tasks);
  }
}

@riverpod
List<TaskModel> filteredTasks(Ref ref) {
  final filter = ref.watch(taskFilterStateProvider);
  final tasks = ref.watch(tasksProvider).value ?? const <TaskModel>[];
  return TaskSort.filterAndSort(tasks, filter: filter);
}
