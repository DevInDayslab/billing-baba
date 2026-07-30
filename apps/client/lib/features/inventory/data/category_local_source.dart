import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/category_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for inventory categories.
class CategoryLocalSource {
  CategoryLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows =
        await (_db.select(_db.categoriesLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<CategoryDto>> listActive(
    String businessId, {
    String? searchQuery,
  }) async {
    final query = _db.select(_db.categoriesLocal)
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

  Stream<List<CategoryDto>> watchActive(String businessId) {
    return (_db.select(_db.categoriesLocal)
          ..where(
            (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(_toDto).toList());
  }

  Future<CategoryTableData?> getById(String id) {
    return (_db.select(
      _db.categoriesLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<CategoryDto?> getActiveDto(String id) async {
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
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
    int itemCount = 0,
  }) {
    return _db
        .into(_db.categoriesLocal)
        .insertOnConflictUpdate(
          CategoriesLocalCompanion.insert(
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

  Future<void> upsertFromDto(String businessId, CategoryDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      name: dto.name,
      syncVersion: 1,
      createdAt: created,
      updatedAt: updated,
      itemCount: dto.itemCount,
    );
  }

  Future<void> updateSyncMeta({
    required String id,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(
      _db.categoriesLocal,
    )..where((t) => t.id.equals(id))).write(
      CategoriesLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) {
    return (_db.update(
      _db.categoriesLocal,
    )..where((t) => t.id.equals(id))).write(
      CategoriesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  CategoryDto _toDto(CategoryTableData row) {
    return CategoryDto(
      id: row.id,
      name: row.name,
      itemCount: row.itemCount,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }
}
