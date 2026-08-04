import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/item_tier_price_dto.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:drift/drift.dart';

class ItemTierPriceLocalSource {
  ItemTierPriceLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows =
        await (_db.select(_db.itemTierPricesLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) & t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<int> countActiveForItem(String businessId, String itemId) async {
    final rows =
        await (_db.select(_db.itemTierPricesLocal)..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.itemId.equals(itemId) &
                  t.isDeleted.equals(false),
            ))
            .get();
    return rows.length;
  }

  Future<List<ItemTierPriceDto>> listActiveForItem(
    String businessId,
    String itemId,
  ) async {
    final rows =
        await (_db.select(_db.itemTierPricesLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) &
                    t.itemId.equals(itemId) &
                    t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.pricingTier)]))
            .get();
    return rows.map(_toDto).toList();
  }

  Future<Map<String, Map<String, double>>> groupedByItemId(
    String businessId,
  ) async {
    final rows =
        await (_db.select(_db.itemTierPricesLocal)
              ..where(
                (t) =>
                    t.businessId.equals(businessId) & t.isDeleted.equals(false),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.itemId),
                (t) => OrderingTerm.asc(t.pricingTier),
              ]))
            .get();
    final grouped = <String, Map<String, double>>{};
    for (final row in rows) {
      if (row.price <= 0) continue;
      final tierKey = PriceTier.fromApiTier(row.pricingTier);
      grouped
          .putIfAbsent(row.itemId, () => {})
          .putIfAbsent(tierKey, () => row.price);
    }
    return grouped;
  }

  Future<ItemTierPriceTableData?> getById(String id) {
    return (_db.select(
      _db.itemTierPricesLocal,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ItemTierPriceDto?> getActiveDto(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toDto(row);
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String itemId,
    required String pricingTier,
    required double price,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db
        .into(_db.itemTierPricesLocal)
        .insertOnConflictUpdate(
          ItemTierPricesLocalCompanion.insert(
            id: id,
            businessId: businessId,
            itemId: itemId,
            pricingTier: pricingTier,
            price: price,
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) async {
    await (_db.update(
      _db.itemTierPricesLocal,
    )..where((t) => t.id.equals(id))).write(
      ItemTierPricesLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  Future<List<ItemTierPriceTableData>> listActiveRowsForItem(
    String businessId,
    String itemId,
  ) {
    return (_db.select(_db.itemTierPricesLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) &
                t.itemId.equals(itemId) &
                t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.pricingTier)]))
        .get();
  }

  ItemTierPriceDto _toDto(ItemTierPriceTableData row) {
    return ItemTierPriceDto(
      id: row.id,
      itemId: row.itemId,
      pricingTier: row.pricingTier,
      price: row.price,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
    );
  }
}
