import 'dart:convert';

import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

/// Applies pull/ack updates for `entity_type: todos` into Drift.
class TodoSync {
  TodoSync(this._db);

  final AppDatabase _db;

  Future<void> applyChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(
      _db.todosLocal,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    if (isDeleted) {
      await _db
          .into(_db.todosLocal)
          .insertOnConflictUpdate(
            TodosLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              title: existing?.title ?? _str(payload, 'title') ?? '',
              description: Value(existing?.description),
              priority: Value(existing?.priority ?? 'medium'),
              category: Value(
                _str(payload, 'category') ?? existing?.category,
              ),
              partyId: Value(
                _str(payload, 'party_id') ?? existing?.partyId,
              ),
              dueDate: Value(_str(payload, 'due_date') ?? existing?.dueDate),
              reminderAt: Value(
                _date(payload, 'reminder_at') ?? existing?.reminderAt,
              ),
              isCompleted: Value(existing?.isCompleted ?? false),
              completedAt: Value(existing?.completedAt),
              isPinned: Value(
                _bool(payload, 'is_pinned') ?? existing?.isPinned ?? false,
              ),
              linkedInvoiceId: Value(existing?.linkedInvoiceId),
              linkedPurchaseId: Value(existing?.linkedPurchaseId),
              linkedProductId: Value(existing?.linkedProductId),
              attachmentIdsJson: Value(existing?.attachmentIdsJson ?? '[]'),
              syncVersion: Value(syncVersion),
              createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
              updatedAt: updatedAt.toUtc(),
              deletedAt: Value((deletedAt ?? updatedAt).toUtc()),
              isDeleted: const Value(true),
              deviceId: Value(deviceId),
            ),
          );
      return;
    }

    await _db
        .into(_db.todosLocal)
        .insertOnConflictUpdate(
          TodosLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            title: _str(payload, 'title') ?? existing?.title ?? '',
            description: Value(
              _str(payload, 'description') ?? existing?.description,
            ),
            priority: Value(
              _str(payload, 'priority') ?? existing?.priority ?? 'medium',
            ),
            category: Value(_str(payload, 'category') ?? existing?.category),
            partyId: Value(_str(payload, 'party_id') ?? existing?.partyId),
            dueDate: Value(_str(payload, 'due_date') ?? existing?.dueDate),
            reminderAt: Value(
              _date(payload, 'reminder_at') ?? existing?.reminderAt,
            ),
            isCompleted: Value(
              _bool(payload, 'is_completed') ?? existing?.isCompleted ?? false,
            ),
            completedAt: Value(
              _date(payload, 'completed_at') ?? existing?.completedAt,
            ),
            isPinned: Value(
              _bool(payload, 'is_pinned') ?? existing?.isPinned ?? false,
            ),
            linkedInvoiceId: Value(
              _str(payload, 'linked_invoice_id') ?? existing?.linkedInvoiceId,
            ),
            linkedPurchaseId: Value(
              _str(payload, 'linked_purchase_id') ?? existing?.linkedPurchaseId,
            ),
            linkedProductId: Value(
              _str(payload, 'linked_product_id') ?? existing?.linkedProductId,
            ),
            attachmentIdsJson: Value(
              _attachmentIdsJson(payload) ??
                  existing?.attachmentIdsJson ??
                  '[]',
            ),
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            isDeleted: const Value(false),
            deletedAt: const Value(null),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> updateAckMeta({
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(
      _db.todosLocal,
    )..where((t) => t.id.equals(entityId))).write(
      TodosLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }

  static String? _str(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value == null) return null;
    return value.toString();
  }

  static bool? _bool(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    return null;
  }

  static DateTime? _date(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String? _attachmentIdsJson(Map<String, dynamic>? payload) {
    final value = payload?['attachment_ids'];
    if (value is! List) return null;
    return jsonEncode(value.map((e) => e.toString()).toList());
  }
}
