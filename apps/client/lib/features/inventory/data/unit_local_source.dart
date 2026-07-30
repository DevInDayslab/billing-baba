import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/unit_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for unit definitions. Does not enqueue SyncJobs.
class UnitLocalSource {
  UnitLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows =
        await (_db.select(_db.unitDefinitionsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<UnitListDto>> listActive(
    String businessId, {
    String? searchQuery,
    bool? isActive,
  }) async {
    final query = _db.select(_db.unitDefinitionsLocal)
      ..where(
        (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    var filtered = rows;
    if (isActive != null) {
      filtered = filtered.where((r) => r.isActive == isActive).toList();
    }
    final q = searchQuery?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      filtered = filtered.where((r) {
        final hay = '${r.name} ${r.shortName} ${r.symbol ?? ''}'.toLowerCase();
        return hay.contains(q);
      }).toList();
    }
    return filtered.map(_toListDto).toList();
  }

  Future<UnitDefinitionTableData?> getById(String id) {
    return (_db.select(
      _db.unitDefinitionsLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<UnitDetailDto?> getActiveDetail(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toDetailDto(row);
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String name,
    required String shortName,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? symbol,
    int decimalPlaces = 0,
    bool isSystem = false,
    bool isActive = true,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db
        .into(_db.unitDefinitionsLocal)
        .insertOnConflictUpdate(
          UnitDefinitionsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            shortName: shortName,
            symbol: Value(symbol),
            decimalPlaces: Value(decimalPlaces),
            isSystem: Value(isSystem),
            isActive: Value(isActive),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertFromDetailDto(String businessId, UnitDetailDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      name: dto.name,
      shortName: dto.shortName,
      symbol: dto.symbol,
      decimalPlaces: dto.decimalPlaces,
      isSystem: dto.isSystem,
      isActive: dto.isActive,
      syncVersion: 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) async {
    await (_db.update(
      _db.unitDefinitionsLocal,
    )..where((t) => t.id.equals(id))).write(
      UnitDefinitionsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  UnitListDto _toListDto(UnitDefinitionTableData row) {
    return UnitListDto(
      id: row.id,
      name: row.name,
      shortName: row.shortName,
      decimalPlaces: row.decimalPlaces,
      isSystem: row.isSystem,
      isActive: row.isActive,
      conversionCount: 0,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
      symbol: row.symbol,
    );
  }

  UnitDetailDto _toDetailDto(UnitDefinitionTableData row) {
    return UnitDetailDto(
      id: row.id,
      name: row.name,
      shortName: row.shortName,
      decimalPlaces: row.decimalPlaces,
      isSystem: row.isSystem,
      isActive: row.isActive,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
      symbol: row.symbol,
    );
  }
}
