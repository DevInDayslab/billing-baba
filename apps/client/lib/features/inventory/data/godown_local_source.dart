import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/godown_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for godowns. Does not enqueue SyncJobs.
class GodownLocalSource {
  GodownLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows =
        await (_db.select(_db.godownsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<GodownDto>> listActive(
    String businessId, {
    String? searchQuery,
  }) async {
    final query = _db.select(_db.godownsLocal)
      ..where(
        (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    final q = searchQuery?.trim().toLowerCase();
    final filtered = q == null || q.isEmpty
        ? rows
        : rows.where((r) => r.name.toLowerCase().contains(q)).toList();
    return filtered.map(_toDto).toList();
  }

  Future<GodownTableData?> getById(String id) {
    return (_db.select(
      _db.godownsLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<GodownDto?> getActiveDto(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toDto(row);
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String name,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? address,
    bool isDefault = false,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db
        .into(_db.godownsLocal)
        .insertOnConflictUpdate(
          GodownsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            address: Value(address),
            isDefault: Value(isDefault),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertFromDto(String businessId, GodownDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      name: dto.name,
      address: dto.address,
      isDefault: dto.isDefault,
      syncVersion: 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) async {
    await (_db.update(_db.godownsLocal)..where((t) => t.id.equals(id))).write(
      GodownsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  GodownDto _toDto(GodownTableData row) {
    return GodownDto(
      id: row.id,
      name: row.name,
      isDefault: row.isDefault,
      stockItemCount: 0,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
      address: row.address,
    );
  }
}
