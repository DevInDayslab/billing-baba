import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/item_supplier_dto.dart';
import 'package:drift/drift.dart';

class ItemSupplierLocalSource {
  ItemSupplierLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows =
        await (_db.select(_db.itemSuppliersLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<int> countActiveForItem(String businessId, String itemId) async {
    final rows =
        await (_db.select(_db.itemSuppliersLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.itemId.equals(itemId) &
                  t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<ItemSupplierDto>> listActiveForItem(
    String businessId,
    String itemId,
  ) async {
    final rows =
        await (_db.select(_db.itemSuppliersLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) &
                    t.itemId.equals(itemId) &
                    t.isDeleted.equals(false),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.sortOrder),
                (t) => OrderingTerm.asc(t.createdAt),
              ]))
            .get();
    return rows.map(_toDto).toList();
  }

  Future<List<ItemSupplierDto>> listActive(String businessId) async {
    final rows =
        await (_db.select(_db.itemSuppliersLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) & t.isDeleted.equals(false),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.itemId),
                (t) => OrderingTerm.asc(t.sortOrder),
                (t) => OrderingTerm.asc(t.createdAt),
              ]))
            .get();
    return rows.map(_toDto).toList();
  }

  Future<Map<String, List<String>>> groupedPartyIds(String businessId) async {
    final rows = await listActive(businessId);
    final grouped = <String, List<String>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.itemId, () => []).add(row.partyId);
    }
    return grouped;
  }

  Future<ItemSupplierTableData?> getById(String id) {
    return (_db.select(
      _db.itemSuppliersLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ItemSupplierDto?> getActiveDto(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toDto(row);
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String itemId,
    required String partyId,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool isDefault = false,
    int sortOrder = 0,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db
        .into(_db.itemSuppliersLocal)
        .insertOnConflictUpdate(
          ItemSuppliersLocalCompanion.insert(
            id: id,
            businessId: businessId,
            itemId: itemId,
            partyId: partyId,
            isDefault: Value(isDefault),
            sortOrder: Value(sortOrder),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertFromDto(String businessId, ItemSupplierDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt ?? '')?.toUtc() ??
        DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt ?? '')?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      itemId: dto.itemId,
      partyId: dto.partyId,
      isDefault: dto.isDefault,
      sortOrder: dto.sortOrder,
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
      _db.itemSuppliersLocal,
    )..where((t) => t.id.equals(id))).write(
      ItemSuppliersLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  Future<List<ItemSupplierTableData>> listActiveRowsForItem(
    String businessId,
    String itemId,
  ) {
    return (_db.select(_db.itemSuppliersLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.itemId.equals(itemId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  ItemSupplierDto _toDto(ItemSupplierTableData row) {
    return ItemSupplierDto(
      id: row.id,
      itemId: row.itemId,
      partyId: row.partyId,
      isDefault: row.isDefault,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }
}
