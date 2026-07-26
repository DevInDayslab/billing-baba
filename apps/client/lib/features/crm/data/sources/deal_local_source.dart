import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/services/storage_service.dart';
import 'package:billing_baba/core/sync/models/sync_queue_enums.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class DealLocalSource {
  DealLocalSource(this._db, this._storage);

  final AppDatabase _db;
  final StorageService _storage;

  String? readBusinessId() => _storage.read(StorageKeys.lastOpenedBusinessId);

  Stream<List<Deal>> watchDeals(String businessId) {
    final query = _db.select(_db.deals)
      ..where(
        (row) =>
            row.businessId.equals(businessId) & row.isDeleted.equals(false),
      )
      ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]);

    return query.watch().map((rows) => rows.map(_dealFromRow).toList());
  }

  Future<List<Deal>> getDeals(String businessId) async {
    final rows =
        await (_db.select(_db.deals)
              ..where(
                (row) =>
                    row.businessId.equals(businessId) &
                    row.isDeleted.equals(false),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.map(_dealFromRow).toList();
  }

  Future<Deal?> getDealById(String businessId, String dealId) async {
    final row =
        await (_db.select(_db.deals)..where(
              (tbl) =>
                  tbl.id.equals(dealId) &
                  tbl.businessId.equals(businessId) &
                  tbl.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    return row == null ? null : _dealFromRow(row);
  }

  Future<void> upsertDeal(Deal deal) async {
    await _db.into(_db.deals).insertOnConflictUpdate(_dealToCompanion(deal));
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

  Deal _dealFromRow(DealTableData row) {
    return Deal(
      id: row.id,
      businessId: row.businessId,
      name: row.name,
      stage: DealStageX.fromWire(row.stage),
      accountName: row.accountName,
      assignedTo: row.assignedTo,
      amount: row.amount,
      expectedCloseDate: row.expectedCloseDate == null
          ? null
          : DateTime.tryParse(row.expectedCloseDate!),
      description: row.description,
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

  DealsCompanion _dealToCompanion(Deal deal) {
    return DealsCompanion.insert(
      id: deal.id,
      businessId: deal.businessId,
      name: deal.name,
      stage: deal.stage.wireValue,
      accountName: Value(deal.accountName),
      assignedTo: Value(deal.assignedTo),
      amount: Value(deal.amount),
      expectedCloseDate: Value(
        deal.expectedCloseDate?.toUtc().toIso8601String(),
      ),
      description: Value(deal.description),
      syncVersion: Value(deal.syncVersion),
      isDeleted: Value(deal.isDeleted),
      updatedAt: deal.updatedAt.toUtc().toIso8601String(),
      deletedAt: Value(deal.deletedAt?.toUtc().toIso8601String()),
      deviceId: Value(deal.deviceId),
      syncStatus: Value(deal.syncStatus),
      createdAt: deal.createdAt.toUtc().toIso8601String(),
    );
  }
}
