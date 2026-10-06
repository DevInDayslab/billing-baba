import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/item_bom_dto.dart';
import 'package:drift/drift.dart';

class ItemBomCostLocalSource {
  ItemBomCostLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActiveForItem(String businessId, String itemId) async {
    final rows =
        await (_db.select(_db.itemBomCostsLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.itemId.equals(itemId) &
                  t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<ItemBomCostDto>> listActiveForItem(
    String businessId,
    String itemId,
  ) async {
    final rows =
        await (_db.select(_db.itemBomCostsLocal)
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

  Future<List<ItemBomCostTableData>> listActiveRowsForItem(
    String businessId,
    String itemId,
  ) {
    return (_db.select(_db.itemBomCostsLocal)
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

  Future<ItemBomCostTableData?> getById(String id) {
    return (_db.select(
      _db.itemBomCostsLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String itemId,
    required String description,
    required double amount,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    int sortOrder = 0,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db
        .into(_db.itemBomCostsLocal)
        .insertOnConflictUpdate(
          ItemBomCostsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            itemId: itemId,
            description: description,
            amount: Value(amount),
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

  Future<void> upsertFromDto(String businessId, ItemBomCostDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt ?? '')?.toUtc() ??
        DateTime.now().toUtc();
    final updated = DateTime.tryParse(dto.updatedAt ?? '')?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      itemId: dto.itemId,
      description: dto.description,
      amount: double.tryParse(dto.amount) ?? 0,
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
      _db.itemBomCostsLocal,
    )..where((t) => t.id.equals(id))).write(
      ItemBomCostsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  ItemBomCostDto _toDto(ItemBomCostTableData row) {
    return ItemBomCostDto(
      id: row.id,
      itemId: row.itemId,
      description: row.description,
      amount: row.amount.toString(),
      sortOrder: row.sortOrder,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }
}
