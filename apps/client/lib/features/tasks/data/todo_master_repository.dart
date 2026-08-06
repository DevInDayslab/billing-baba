import 'dart:convert';

import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/tasks/data/todo_local_source.dart';
import 'package:billing_baba/features/tasks/data/todo_repository.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _todosEntity = 'todos';

/// Local-first todo writes + SyncQueue enqueue (Parties pattern).
class TodoMasterRepository {
  TodoMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._storage,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final TodoLocalSource _local;
  final SyncQueue _syncQueue;
  final TodoRepository _remote;
  final StorageService _storage;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for todo operations');
    }
    return id;
  }

  Future<List<TaskModel>> listActive() async {
    final businessId = _requireBusinessId();
    await migrateFromLegacyStorageIfNeeded();
    await _hydrateIfEmpty(businessId);
    return _local.listActive(businessId);
  }

  Future<TaskModel> create({
    required String title,
    String? description,
    TaskCategory? category,
    DateTime? reminderAt,
  }) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final trimmed = title.trim();

    await _local.upsertRow(
      id: id,
      businessId: businessId,
      title: trimmed,
      description: _nullableTrim(description),
      category: category?.toJson(),
      reminderAt: reminderAt,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _todosEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: _domainPayload(
        title: trimmed,
        description: _nullableTrim(description),
        category: category,
        reminderAt: reminderAt,
      ),
      clientUpdatedAt: now,
    );

    return (await _local.getModelById(id))!;
  }

  Future<TaskModel> createFromTask(TaskModel task) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();

    await _local.upsertRow(
      id: task.id,
      businessId: businessId,
      title: task.title.trim(),
      description: task.description,
      category: task.category?.toJson(),
      partyId: task.linkedPartyId,
      reminderAt: task.reminderAt,
      isCompleted: task.isCompleted,
      completedAt: task.completedAt?.toUtc(),
      isPinned: task.isPinned,
      linkedInvoiceId: task.linkedInvoiceId,
      linkedPurchaseId: task.linkedPurchaseId,
      linkedProductId: task.linkedProductId,
      attachmentIds: task.attachmentIds,
      syncVersion: 0,
      createdAt: task.createdAt.toUtc(),
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _todosEntity,
      entityId: task.id,
      operation: SyncQueueOperation.create,
      payload: _domainPayloadFromTask(task),
      clientUpdatedAt: now,
    );

    return (await _local.getModelById(task.id))!;
  }

  Future<TaskModel> update(TaskModel task) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(task.id);
    if (existing == null || existing.isDeleted) {
      throw StateError('Todo not found');
    }

    final now = DateTime.now().toUtc();
    await _local.upsertRow(
      id: task.id,
      businessId: businessId,
      title: task.title.trim(),
      description: task.description,
      category: task.category?.toJson(),
      partyId: task.linkedPartyId,
      reminderAt: task.reminderAt,
      isCompleted: task.isCompleted,
      completedAt: task.completedAt?.toUtc(),
      isPinned: task.isPinned,
      linkedInvoiceId: task.linkedInvoiceId,
      linkedPurchaseId: task.linkedPurchaseId,
      linkedProductId: task.linkedProductId,
      attachmentIds: task.attachmentIds,
      syncVersion: existing.syncVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _todosEntity,
      entityId: task.id,
      operation: SyncQueueOperation.update,
      baseSyncVersion: existing.syncVersion,
      payload: _domainPayloadFromTask(task),
      clientUpdatedAt: now,
    );

    return (await _local.getModelById(task.id))!;
  }

  Future<void> softDelete(String id) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) return;

    final now = DateTime.now().toUtc();
    await _local.softDelete(
      id: id,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
    );

    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _todosEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      baseSyncVersion: existing.syncVersion,
      payload: const {},
      clientUpdatedAt: now,
    );
  }

  Future<void> migrateFromLegacyStorageIfNeeded() async {
    final businessId = _requireBusinessId();
    final migratedKey = StorageKeys.dashboardTasksMigratedFor(businessId);
    if (_storage.read(migratedKey) == 'true') return;

    if (await _local.countActive(businessId) > 0) {
      await _storage.write(migratedKey, 'true');
      await _storage.remove('${StorageKeys.dashboardTasks}_$businessId');
      return;
    }

    final raw = _storage.read('${StorageKeys.dashboardTasks}_$businessId');
    if (raw == null || raw.isEmpty) {
      await _storage.write(migratedKey, 'true');
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final now = DateTime.now().toUtc();
        for (final entry in decoded) {
          if (entry is! Map<Object?, Object?>) continue;
          final task = TaskModel.fromJson(Map<String, dynamic>.from(entry));
          await _local.upsertRow(
            id: task.id,
            businessId: businessId,
            title: task.title,
            description: task.description,
            category: task.category?.toJson(),
            partyId: task.linkedPartyId,
            reminderAt: task.reminderAt,
            isCompleted: task.isCompleted,
            completedAt: task.completedAt?.toUtc(),
            isPinned: task.isPinned,
            linkedInvoiceId: task.linkedInvoiceId,
            linkedPurchaseId: task.linkedPurchaseId,
            linkedProductId: task.linkedProductId,
            attachmentIds: task.attachmentIds,
            syncVersion: 0,
            createdAt: task.createdAt.toUtc(),
            updatedAt: task.updatedAt.toUtc(),
            deviceId: _deviceIdReader?.call(),
          );
          await _syncQueue.enqueueRowMutation(
            businessId: businessId,
            deviceId: _deviceIdReader?.call(),
            entityType: _todosEntity,
            entityId: task.id,
            operation: SyncQueueOperation.create,
            payload: _domainPayloadFromTask(task),
            clientUpdatedAt: now,
          );
        }
      }
    } on Object {
      // Ignore corrupt legacy cache.
    }

    await _storage.write(migratedKey, 'true');
    await _storage.remove('${StorageKeys.dashboardTasks}_$businessId');
  }

  Future<void> _hydrateIfEmpty(String businessId) async {
    if (await _local.countActive(businessId) > 0) return;
    try {
      final remote = await _remote.listTodos();
      for (final dto in remote) {
        await _local.upsertRow(
          id: dto.id,
          businessId: businessId,
          title: dto.title,
          description: dto.description,
          priority: dto.priority,
          category: dto.category,
          partyId: dto.partyId,
          dueDate: dto.dueDate,
          reminderAt: dto.reminderAt,
          isCompleted: dto.isCompleted,
          completedAt: dto.completedAt,
          isPinned: dto.isPinned,
          linkedInvoiceId: dto.linkedInvoiceId,
          linkedPurchaseId: dto.linkedPurchaseId,
          linkedProductId: dto.linkedProductId,
          attachmentIds: dto.attachmentIds,
          syncVersion: dto.syncVersion,
          createdAt: dto.createdAt,
          updatedAt: dto.updatedAt,
        );
      }
    } on Object {
      // Offline — local stays empty until sync pull.
    }
  }

  Map<String, dynamic> _domainPayload({
    required String title,
    String? description,
    TaskCategory? category,
    DateTime? reminderAt,
    bool isCompleted = false,
    DateTime? completedAt,
    bool isPinned = false,
    String? partyId,
    String? linkedInvoiceId,
    String? linkedPurchaseId,
    String? linkedProductId,
    List<String> attachmentIds = const [],
  }) {
    return {
      'title': title,
      'description': ?description,
      'priority': 'medium',
      if (category != null) 'category': category.toJson(),
      'party_id': ?partyId,
      if (reminderAt != null) 'reminder_at': reminderAt.toUtc().toIso8601String(),
      'is_completed': isCompleted,
      if (completedAt != null)
        'completed_at': completedAt.toUtc().toIso8601String(),
      'is_pinned': isPinned,
      'linked_invoice_id': ?linkedInvoiceId,
      'linked_purchase_id': ?linkedPurchaseId,
      'linked_product_id': ?linkedProductId,
      'attachment_ids': attachmentIds,
    };
  }

  Map<String, dynamic> _domainPayloadFromTask(TaskModel task) {
    return _domainPayload(
      title: task.title,
      description: task.description,
      category: task.category,
      reminderAt: task.reminderAt,
      isCompleted: task.isCompleted,
      completedAt: task.completedAt,
      isPinned: task.isPinned,
      partyId: task.linkedPartyId,
      linkedInvoiceId: task.linkedInvoiceId,
      linkedPurchaseId: task.linkedPurchaseId,
      linkedProductId: task.linkedProductId,
      attachmentIds: task.attachmentIds,
    );
  }

  static String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
