import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/engine/sync_apply_guard.dart';
import 'package:drift/drift.dart';

class LeadSync {
  LeadSync(this._db);

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
      _db.leads,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    final updatedIso = updatedAt.toUtc().toIso8601String();
    final deletedIso = (deletedAt ?? updatedAt).toUtc().toIso8601String();
    final createdIso =
        _str(payload, 'created_at') ?? existing?.createdAt ?? updatedIso;

    await _db
        .into(_db.leads)
        .insertOnConflictUpdate(
          LeadsCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: _str(payload, 'name') ?? existing?.name ?? '',
            company: Value(_str(payload, 'company') ?? existing?.company),
            phone: Value(_str(payload, 'phone') ?? existing?.phone),
            email: Value(_str(payload, 'email') ?? existing?.email),
            leadSource: Value(
              _str(payload, 'lead_source') ?? existing?.leadSource,
            ),
            status: Value(_str(payload, 'status') ?? existing?.status ?? 'new'),
            assignedTo: Value(
              _str(payload, 'assigned_to') ?? existing?.assignedTo,
            ),
            notes: Value(_str(payload, 'notes') ?? existing?.notes),
            syncVersion: Value(syncVersion),
            isDeleted: Value(isDeleted),
            updatedAt: updatedIso,
            deletedAt: Value(isDeleted ? deletedIso : null),
            deviceId: Value(deviceId ?? existing?.deviceId ?? ''),
            syncStatus: const Value('synced'),
            createdAt: createdIso,
          ),
        );
  }

  Future<void> updateAckMeta({
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(_db.leads)..where((t) => t.id.equals(entityId))).write(
      LeadsCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc().toIso8601String()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
        syncStatus: const Value('synced'),
      ),
    );
  }
}

class LeadActivitySync {
  LeadActivitySync(this._db);

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
      _db.leadActivities,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    final updatedIso = updatedAt.toUtc().toIso8601String();
    final deletedIso = (deletedAt ?? updatedAt).toUtc().toIso8601String();
    final createdIso =
        _str(payload, 'created_at') ?? existing?.createdAt ?? updatedIso;
    final leadId = _str(payload, 'lead_id') ?? existing?.leadId ?? '';

    await _db
        .into(_db.leadActivities)
        .insertOnConflictUpdate(
          LeadActivitiesCompanion.insert(
            id: entityId,
            leadId: leadId,
            businessId: businessId,
            type: _str(payload, 'type') ?? existing?.type ?? 'note',
            notes: Value(_str(payload, 'notes') ?? existing?.notes),
            addedBy: Value(_str(payload, 'added_by') ?? existing?.addedBy),
            syncVersion: Value(syncVersion),
            isDeleted: Value(isDeleted),
            updatedAt: updatedIso,
            deletedAt: Value(isDeleted ? deletedIso : null),
            deviceId: Value(deviceId ?? existing?.deviceId ?? ''),
            syncStatus: const Value('synced'),
            createdAt: createdIso,
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
      _db.leadActivities,
    )..where((t) => t.id.equals(entityId))).write(
      LeadActivitiesCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc().toIso8601String()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
        syncStatus: const Value('synced'),
      ),
    );
  }
}

class ContactSync {
  ContactSync(this._db);

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
      _db.contacts,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    final updatedIso = updatedAt.toUtc().toIso8601String();
    final deletedIso = (deletedAt ?? updatedAt).toUtc().toIso8601String();
    final createdIso =
        _str(payload, 'created_at') ?? existing?.createdAt ?? updatedIso;

    await _db
        .into(_db.contacts)
        .insertOnConflictUpdate(
          ContactsCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: _str(payload, 'name') ?? existing?.name ?? '',
            firstName: Value(
              _str(payload, 'first_name') ?? existing?.firstName,
            ),
            lastName: Value(_str(payload, 'last_name') ?? existing?.lastName),
            salutation: Value(
              _str(payload, 'salutation') ?? existing?.salutation,
            ),
            accountName: Value(
              _str(payload, 'account_name') ?? existing?.accountName,
            ),
            phone: Value(_str(payload, 'phone') ?? existing?.phone),
            email: Value(_str(payload, 'email') ?? existing?.email),
            assignedTo: Value(
              _str(payload, 'assigned_to') ?? existing?.assignedTo,
            ),
            title: Value(_str(payload, 'title') ?? existing?.title),
            description: Value(
              _str(payload, 'description') ?? existing?.description,
            ),
            syncVersion: Value(syncVersion),
            isDeleted: Value(isDeleted),
            updatedAt: updatedIso,
            deletedAt: Value(isDeleted ? deletedIso : null),
            deviceId: Value(deviceId ?? existing?.deviceId ?? ''),
            syncStatus: const Value('synced'),
            createdAt: createdIso,
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
      _db.contacts,
    )..where((t) => t.id.equals(entityId))).write(
      ContactsCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc().toIso8601String()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
        syncStatus: const Value('synced'),
      ),
    );
  }
}

class ContactActivitySync {
  ContactActivitySync(this._db);

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
      _db.contactActivities,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    final updatedIso = updatedAt.toUtc().toIso8601String();
    final deletedIso = (deletedAt ?? updatedAt).toUtc().toIso8601String();
    final createdIso =
        _str(payload, 'created_at') ?? existing?.createdAt ?? updatedIso;
    final contactId = _str(payload, 'contact_id') ?? existing?.contactId ?? '';

    await _db
        .into(_db.contactActivities)
        .insertOnConflictUpdate(
          ContactActivitiesCompanion.insert(
            id: entityId,
            contactId: contactId,
            businessId: businessId,
            type: _str(payload, 'type') ?? existing?.type ?? 'note',
            notes: Value(_str(payload, 'notes') ?? existing?.notes),
            addedBy: Value(_str(payload, 'added_by') ?? existing?.addedBy),
            syncVersion: Value(syncVersion),
            isDeleted: Value(isDeleted),
            updatedAt: updatedIso,
            deletedAt: Value(isDeleted ? deletedIso : null),
            deviceId: Value(deviceId ?? existing?.deviceId ?? ''),
            syncStatus: const Value('synced'),
            createdAt: createdIso,
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
      _db.contactActivities,
    )..where((t) => t.id.equals(entityId))).write(
      ContactActivitiesCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc().toIso8601String()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
        syncStatus: const Value('synced'),
      ),
    );
  }
}

class DealSync {
  DealSync(this._db);

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
      _db.deals,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();

    if (!shouldApplyPullChange(
      incomingSyncVersion: syncVersion,
      existingSyncVersion: existing?.syncVersion,
      isDeleted: isDeleted,
    )) {
      return;
    }

    final updatedIso = updatedAt.toUtc().toIso8601String();
    final deletedIso = (deletedAt ?? updatedAt).toUtc().toIso8601String();
    final createdIso =
        _str(payload, 'created_at') ?? existing?.createdAt ?? updatedIso;
    final amount = _readDouble(payload?['amount']) ?? existing?.amount ?? 0;

    await _db
        .into(_db.deals)
        .insertOnConflictUpdate(
          DealsCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: _str(payload, 'name') ?? existing?.name ?? '',
            stage: _str(payload, 'stage') ?? existing?.stage ?? 'prospecting',
            accountName: Value(
              _str(payload, 'account_name') ?? existing?.accountName,
            ),
            assignedTo: Value(
              _str(payload, 'assigned_to') ?? existing?.assignedTo,
            ),
            amount: Value(amount),
            expectedCloseDate: Value(
              _str(payload, 'expected_close_date') ??
                  existing?.expectedCloseDate,
            ),
            description: Value(
              _str(payload, 'description') ?? existing?.description,
            ),
            syncVersion: Value(syncVersion),
            isDeleted: Value(isDeleted),
            updatedAt: updatedIso,
            deletedAt: Value(isDeleted ? deletedIso : null),
            deviceId: Value(deviceId ?? existing?.deviceId ?? ''),
            syncStatus: const Value('synced'),
            createdAt: createdIso,
          ),
        );
  }

  Future<void> updateAckMeta({
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(_db.deals)..where((t) => t.id.equals(entityId))).write(
      DealsCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc().toIso8601String()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
        syncStatus: const Value('synced'),
      ),
    );
  }
}

String? _str(Map<String, dynamic>? payload, String key) {
  final value = payload?[key];
  if (value == null) return null;
  return value.toString();
}

double? _readDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
