import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/tasks/models/task_category.dart';
import 'package:billing_baba/features/tasks/models/task_model.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for dashboard todos. Does not enqueue SyncJobs.
class TodoLocalSource {
  TodoLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows =
        await (_db.select(_db.todosLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<TaskModel>> listActive(String businessId) async {
    final rows =
        await (_db.select(_db.todosLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) & t.isDeleted.equals(false),
              )
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.isPinned,
                  mode: OrderingMode.desc,
                ),
                (t) => OrderingTerm.desc(t.updatedAt),
              ]))
            .get();
    return rows.map(_toModel).toList();
  }

  Stream<List<TaskModel>> watchActive(String businessId) {
    return (_db.select(_db.todosLocal)
          ..where(
            (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.isPinned,
              mode: OrderingMode.desc,
            ),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch()
        .map((rows) => rows.map(_toModel).toList());
  }

  Future<TaskModel?> getModelById(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toModel(row);
  }

  Future<TodoTableData?> getById(String id) {
    return (_db.select(
      _db.todosLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String title,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String priority = 'medium',
    String? category,
    String? partyId,
    String? dueDate,
    DateTime? reminderAt,
    bool isCompleted = false,
    DateTime? completedAt,
    bool isPinned = false,
    String? linkedInvoiceId,
    String? linkedPurchaseId,
    String? linkedProductId,
    List<String> attachmentIds = const [],
    bool isDeleted = false,
    DateTime? deletedAt,
    String? deviceId,
  }) {
    return _db
        .into(_db.todosLocal)
        .insertOnConflictUpdate(
          TodosLocalCompanion.insert(
            id: id,
            businessId: businessId,
            title: title,
            description: Value(description),
            priority: Value(priority),
            category: Value(category),
            partyId: Value(partyId),
            dueDate: Value(dueDate),
            reminderAt: Value(reminderAt),
            isCompleted: Value(isCompleted),
            completedAt: Value(completedAt),
            isPinned: Value(isPinned),
            linkedInvoiceId: Value(linkedInvoiceId),
            linkedPurchaseId: Value(linkedPurchaseId),
            linkedProductId: Value(linkedProductId),
            attachmentIdsJson: Value(jsonEncode(attachmentIds)),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            isDeleted: Value(isDeleted),
            deletedAt: Value(deletedAt?.toUtc()),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> softDelete({
    required String id,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(_db.todosLocal)..where((t) => t.id.equals(id))).write(
      TodosLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(updatedAt.toUtc()),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }

  TaskModel _toModel(TodoTableData row) {
    return TaskModel(
      id: row.id,
      title: row.title,
      description: row.description,
      category: row.category == null
          ? null
          : TaskCategoryStyle.fromJson(row.category),
      reminderAt: row.reminderAt,
      isCompleted: row.isCompleted,
      isPinned: row.isPinned,
      createdAt: row.createdAt.toLocal(),
      updatedAt: row.updatedAt.toLocal(),
      completedAt: row.completedAt?.toLocal(),
      linkedInvoiceId: row.linkedInvoiceId,
      linkedPartyId: row.partyId,
      linkedPurchaseId: row.linkedPurchaseId,
      linkedProductId: row.linkedProductId,
      attachmentIds: _decodeAttachmentIds(row.attachmentIdsJson),
    );
  }

  static List<String> _decodeAttachmentIds(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.map((e) => e.toString()).toList();
    } on Object {
      return const [];
    }
  }
}
