import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/features/crm/domain/models/lead.dart';
import 'package:billing_baba/features/crm/domain/models/lead_activity.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class LeadLocalSource {
  LeadLocalSource(this._db, this._storage);

  final AppDatabase _db;
  final StorageService _storage;

  String? readBusinessId() => _storage.read(StorageKeys.lastOpenedBusinessId);

  Stream<List<Lead>> watchLeads(String businessId) {
    final query = _db.select(_db.leads)
      ..where(
        (row) =>
            row.businessId.equals(businessId) & row.isDeleted.equals(false),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);

    return query.watch().map((rows) => rows.map(_leadFromRow).toList());
  }

  Future<List<Lead>> getLeads(String businessId) async {
    final rows =
        await (_db.select(_db.leads)
              ..where(
                (row) =>
                    row.businessId.equals(businessId) &
                    row.isDeleted.equals(false),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.map(_leadFromRow).toList();
  }

  Future<Lead?> getLeadById(String businessId, String leadId) async {
    final row =
        await (_db.select(_db.leads)..where(
              (tbl) =>
                  tbl.id.equals(leadId) &
                  tbl.businessId.equals(businessId) &
                  tbl.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    return row == null ? null : _leadFromRow(row);
  }

  Stream<List<LeadActivity>> watchActivities(String businessId, String leadId) {
    final query = _db.select(_db.leadActivities)
      ..where(
        (row) =>
            row.businessId.equals(businessId) &
            row.leadId.equals(leadId) &
            row.isDeleted.equals(false),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);

    return query.watch().map((rows) => rows.map(_activityFromRow).toList());
  }

  Future<void> upsertLead(Lead lead) async {
    await _db.into(_db.leads).insertOnConflictUpdate(_leadToCompanion(lead));
  }

  Future<void> upsertActivity(LeadActivity activity) async {
    await _db
        .into(_db.leadActivities)
        .insertOnConflictUpdate(_activityToCompanion(activity));
  }

  Future<void> enqueueSyncOperation({
    required String businessId,
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required String createdAt,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            id: id,
            mutationId: _uuid.v4(),
            kind: SyncQueueKind.row.wire,
            entityType: entityType,
            entityId: Value(entityId),
            operation: operation,
            payload: payload,
            businessId: businessId,
            status: SyncQueueStatus.pending.wire,
            priority: Value(SyncQueuePriority.normal.value),
            createdAt: DateTime.tryParse(createdAt)?.toUtc() ??
                DateTime.now().toUtc(),
          ),
        );
  }

  Lead _leadFromRow(LeadTableData row) {
    return Lead(
      id: row.id,
      businessId: row.businessId,
      name: row.name,
      company: row.company,
      phone: row.phone,
      email: row.email,
      leadSource: LeadSourceX.fromWire(row.leadSource),
      status: LeadStatusX.fromWire(row.status),
      assignedTo: row.assignedTo,
      notes: row.notes,
      syncVersion: row.syncVersion,
      isDeleted: row.isDeleted,
      updatedAt: DateTime.parse(row.updatedAt),
      deletedAt: row.deletedAt == null
          ? null
          : DateTime.tryParse(row.deletedAt!),
      deviceId: row.deviceId,
      syncStatus: row.syncStatus,
      createdAt: DateTime.parse(row.createdAt),
    );
  }

  LeadActivity _activityFromRow(LeadActivityTableData row) {
    return LeadActivity(
      id: row.id,
      leadId: row.leadId,
      businessId: row.businessId,
      type: LeadActivityTypeX.fromWire(row.type),
      notes: row.notes,
      addedBy: row.addedBy,
      syncVersion: row.syncVersion,
      isDeleted: row.isDeleted,
      updatedAt: DateTime.parse(row.updatedAt),
      deletedAt: row.deletedAt == null
          ? null
          : DateTime.tryParse(row.deletedAt!),
      deviceId: row.deviceId,
      syncStatus: row.syncStatus,
      createdAt: DateTime.parse(row.createdAt),
    );
  }

  LeadsCompanion _leadToCompanion(Lead lead) {
    return LeadsCompanion.insert(
      id: lead.id,
      businessId: lead.businessId,
      name: lead.name,
      company: Value(lead.company),
      phone: Value(lead.phone),
      email: Value(lead.email),
      leadSource: Value(lead.leadSource?.wireValue),
      status: Value(lead.status.wireValue),
      assignedTo: Value(lead.assignedTo),
      notes: Value(lead.notes),
      syncVersion: Value(lead.syncVersion),
      isDeleted: Value(lead.isDeleted),
      updatedAt: lead.updatedAt.toUtc().toIso8601String(),
      deletedAt: Value(lead.deletedAt?.toUtc().toIso8601String()),
      deviceId: Value(lead.deviceId),
      syncStatus: Value(lead.syncStatus),
      createdAt: lead.createdAt.toUtc().toIso8601String(),
    );
  }

  LeadActivitiesCompanion _activityToCompanion(LeadActivity activity) {
    return LeadActivitiesCompanion.insert(
      id: activity.id,
      leadId: activity.leadId,
      businessId: activity.businessId,
      type: activity.type.wireValue,
      notes: Value(activity.notes),
      addedBy: Value(activity.addedBy),
      syncVersion: Value(activity.syncVersion),
      isDeleted: Value(activity.isDeleted),
      updatedAt: activity.updatedAt.toUtc().toIso8601String(),
      deletedAt: Value(activity.deletedAt?.toUtc().toIso8601String()),
      deviceId: Value(activity.deviceId),
      syncStatus: Value(activity.syncStatus),
      createdAt: activity.createdAt.toUtc().toIso8601String(),
    );
  }
}
