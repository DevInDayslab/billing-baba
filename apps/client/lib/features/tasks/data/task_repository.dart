import 'package:billing_baba/core/database/app_database_provider.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/tasks/data/todo_local_source.dart';
import 'package:billing_baba/features/tasks/data/todo_master_repository.dart';
import 'package:billing_baba/features/tasks/data/todo_repository.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'task_repository.g.dart';

@Riverpod(keepAlive: true)
Future<TodoMasterRepository> todoMasterRepository(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final storage = await ref.watch(storageServiceProvider.future);
  final api = await ref.watch(apiClientProvider.future);
  String? deviceId;
  try {
    final identity = await ref.watch(syncDeviceIdentityProvider.future);
    deviceId = await identity.deviceId();
  } on Object {
    deviceId = null;
  }
  return TodoMasterRepository(
    local: TodoLocalSource(db),
    syncQueue: ref.watch(syncQueueProvider),
    remote: TodoRepository(api.dio),
    storage: storage,
    businessIdReader: () => ref.read(currentBusinessProvider)?.id ?? '',
    deviceIdReader: () => deviceId,
  );
}

/// Facade preserving the legacy [TaskRepository] API for task UI/providers.
class TaskRepository {
  TaskRepository(this._master);

  final TodoMasterRepository _master;
  static const _uuid = Uuid();

  Future<List<TaskModel>> load(String businessId) async {
    return _master.listActive();
  }

  TaskModel create({
    required String title,
    String? description,
    TaskCategory? category,
    DateTime? reminderAt,
  }) {
    final now = DateTime.now();
    return TaskModel(
      id: _uuid.v4(),
      title: title.trim(),
      description: _nullableTrim(description),
      category: category,
      reminderAt: reminderAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  TaskModel duplicate(TaskModel source) {
    final now = DateTime.now();
    return source.copyWith(
      id: _uuid.v4(),
      isCompleted: false,
      isPinned: false,
      clearCompletedAt: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  List<TaskModel>? togglePin(List<TaskModel> tasks, String id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return tasks;

    final task = tasks[index];
    if (!task.isPinned) {
      final pinnedCount = tasks.where((t) => t.isPinned).length;
      if (pinnedCount >= TaskModel.maxPinned) return null;
    }

    final updated = List<TaskModel>.from(tasks);
    updated[index] = task.copyWith(
      isPinned: !task.isPinned,
      updatedAt: DateTime.now(),
    );
    return updated;
  }

  List<TaskModel> upsert(List<TaskModel> tasks, TaskModel task) {
    final updated = List<TaskModel>.from(tasks);
    final index = updated.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      updated.add(task);
    } else {
      updated[index] = task;
    }
    return updated;
  }

  List<TaskModel> remove(List<TaskModel> tasks, String id) {
    return tasks.where((t) => t.id != id).toList();
  }

  List<TaskModel> clearCompleted(List<TaskModel> tasks) {
    return tasks.where((t) => !t.isCompleted).toList();
  }

  Future<TaskModel> persistCreate({
    required String title,
    String? description,
    TaskCategory? category,
    DateTime? reminderAt,
  }) {
    return _master.create(
      title: title,
      description: description,
      category: category,
      reminderAt: reminderAt,
    );
  }

  Future<TaskModel> persistUpdate(TaskModel task) => _master.update(task);

  Future<TaskModel> persistDuplicate(TaskModel source) async {
    final copy = duplicate(source);
    return _master.createFromTask(copy);
  }

  Future<void> persistDelete(String id) => _master.softDelete(id);

  static String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

@Riverpod(keepAlive: true)
Future<TaskRepository> taskRepository(Ref ref) async {
  final master = await ref.watch(todoMasterRepositoryProvider.future);
  return TaskRepository(master);
}
