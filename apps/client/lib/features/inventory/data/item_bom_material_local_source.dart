import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/item_bom_dto.dart';
import 'package:drift/drift.dart';

class ItemBomMaterialLocalSource {
  ItemBomMaterialLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActiveForItem(String businessId, String itemId) async {
    final rows =
        await (_db.select(_db.itemBomMaterialsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.itemId.equals(itemId) &
                  t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<ItemBomMaterialDto>> listActiveForItem(
    String businessId,
    String itemId,
  ) async {
    final rows =
        await (_db.select(_db.itemBomMaterialsLocal)
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

  Future<List<ItemBomMaterialTableData>> listActiveRowsForItem(
    String businessId,
    String itemId,
  ) {
    return (_db.select(_db.itemBomMaterialsLocal)
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

  Future<ItemBomMaterialTableData?> getById(String id) {
    return (_db.select(
      _db.itemBomMaterialsLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String itemId,
    required String rawItemId,
    required double qty,
    required String unitId,
    required double purchasePrice,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    int sortOrder = 0,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db
        .into(_db.itemBomMaterialsLocal)
        .insertOnConflictUpdate(
          ItemBomMaterialsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            itemId: itemId,
            rawItemId: rawItemId,
            qty: qty,
            unitId: unitId,
            purchasePrice: Value(purchasePrice),
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

  Future<void> upsertFromDto(String businessId, ItemBomMaterialDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt ?? '')?.toUtc() ??
        DateTime.now().toUtc();
    final updated =
        DateTime.tryParse(dto.updatedAt ?? '')?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      itemId: dto.itemId,
      rawItemId: dto.rawItemId,
      qty: double.tryParse(dto.qty) ?? 0,
      unitId: dto.unitId,
      purchasePrice: double.tryParse(dto.purchasePrice) ?? 0,
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
      _db.itemBomMaterialsLocal,
    )..where((t) => t.id.equals(id))).write(
      ItemBomMaterialsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  ItemBomMaterialDto _toDto(ItemBomMaterialTableData row) {
    return ItemBomMaterialDto(
      id: row.id,
      itemId: row.itemId,
      rawItemId: row.rawItemId,
      qty: row.qty.toString(),
      unitId: row.unitId,
      purchasePrice: row.purchasePrice.toString(),
      sortOrder: row.sortOrder,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }
}
