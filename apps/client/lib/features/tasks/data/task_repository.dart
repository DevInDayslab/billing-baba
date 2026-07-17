import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskRepository {
  TaskRepository(this._storage);

  final StorageService _storage;
  static const _uuid = Uuid();

  String _key(String businessId) => '${StorageKeys.dashboardTasks}_$businessId';

  Future<List<TaskModel>> load(String businessId) async {
    final raw = _storage.read(_key(businessId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<Object?, Object?>>()
          .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on Object {
      return [];
    }
  }

  Future<void> save(String businessId, List<TaskModel> tasks) async {
    final payload = tasks.map((t) => t.toJson()).toList();
    await _storage.write(_key(businessId), jsonEncode(payload));
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

  /// Returns updated list, or `null` if pin cap would be exceeded.
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

  static String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
