import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/brand_dto.dart';
import 'package:drift/drift.dart';

class BrandLocalSource {
  BrandLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows = await (_db.select(_db.brandsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          ))
        .get();
    return rows.length;
  }

  Future<List<BrandDto>> listActive(
    String businessId, {
    String? searchQuery,
  }) async {
    final rows = await (_db.select(_db.brandsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    final q = searchQuery?.trim().toLowerCase();
    final filtered = q == null || q.isEmpty
        ? rows
        : rows.where((r) => r.name.toLowerCase().contains(q)).toList();
    return filtered.map(_toDto).toList();
  }

  Future<BrandTableData?> getById(String id) {
    return (_db.select(_db.brandsLocal)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<BrandDto?> getActiveDto(String id) async {
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
    int itemCount = 0,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db.into(_db.brandsLocal).insertOnConflictUpdate(
          BrandsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
            itemCount: Value(itemCount),
          ),
        );
  }

  Future<void> upsertFromDto(String businessId, BrandDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated =
        DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      name: dto.name,
      itemCount: dto.itemCount,
      syncVersion: 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) async {
    await (_db.update(_db.brandsLocal)..where((t) => t.id.equals(id))).write(
      BrandsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  BrandDto _toDto(BrandTableData row) {
    return BrandDto(
      id: row.id,
      name: row.name,
      itemCount: row.itemCount,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }
}
