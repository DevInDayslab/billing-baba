import 'package:billing_baba/core/database/database.dart';
import 'package:drift/drift.dart';

/// Applies pull/ack updates for `entity_type: items` into Drift.
class ItemSync {
  ItemSync(this._db);

  final AppDatabase _db;

  Future<void> applyChange({
    required String businessId,
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    required bool isDeleted,
    DateTime? deletedAt,
    String? deviceId,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await (_db.select(_db.itemsLocal)
          ..where((t) => t.id.equals(entityId)))
        .getSingleOrNull();

    if (isDeleted) {
      await _db.into(_db.itemsLocal).insertOnConflictUpdate(
            ItemsLocalCompanion.insert(
              id: entityId,
              businessId: businessId,
              name: existing?.name ?? _str(payload, 'name') ?? '',
              shortName: Value(existing?.shortName),
              alias: Value(existing?.alias),
              searchKeywords: Value(existing?.searchKeywords),
              description: Value(existing?.description),
              itemType: Value(existing?.itemType ?? 'product'),
              hasStockTracking: Value(existing?.hasStockTracking ?? true),
              categoryId: Value(existing?.categoryId),
              brandId: Value(existing?.brandId),
              hsnCode: Value(existing?.hsnCode),
              barcode: Value(existing?.barcode),
              baseUnit: Value(existing?.baseUnit ?? 'piece'),
              mrp: Value(existing?.mrp),
              isMrpOnly: Value(existing?.isMrpOnly ?? false),
              marketPrice: Value(existing?.marketPrice),
              salePrice: Value(existing?.salePrice ?? '0'),
              purchasePrice: Value(existing?.purchasePrice ?? '0'),
              reorderLevel: Value(existing?.reorderLevel),
              defaultTaxRate: Value(existing?.defaultTaxRate),
              primaryImageUrl: Value(existing?.primaryImageUrl),
              syncVersion: Value(syncVersion),
              createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
              updatedAt: updatedAt.toUtc(),
              deletedAt: Value((deletedAt ?? updatedAt).toUtc()),
              isDeleted: const Value(true),
              deviceId: Value(deviceId),
            ),
          );
      return;
    }

    final name = _str(payload, 'name');
    await _db.into(_db.itemsLocal).insertOnConflictUpdate(
          ItemsLocalCompanion.insert(
            id: entityId,
            businessId: businessId,
            name: (name != null && name.isNotEmpty)
                ? name
                : (existing?.name ?? ''),
            shortName:
                Value(_str(payload, 'short_name') ?? existing?.shortName),
            alias: Value(_str(payload, 'alias') ?? existing?.alias),
            searchKeywords: Value(
              _keywords(payload) ?? existing?.searchKeywords,
            ),
            description:
                Value(_str(payload, 'description') ?? existing?.description),
            itemType: Value(
              _str(payload, 'item_type') ?? existing?.itemType ?? 'product',
            ),
            hasStockTracking: Value(
              _bool(payload, 'has_stock_tracking') ??
                  existing?.hasStockTracking ??
                  true,
            ),
            categoryId:
                Value(_str(payload, 'category_id') ?? existing?.categoryId),
            brandId: Value(_str(payload, 'brand_id') ?? existing?.brandId),
            hsnCode: Value(_str(payload, 'hsn_code') ?? existing?.hsnCode),
            barcode: Value(_str(payload, 'barcode') ?? existing?.barcode),
            baseUnit: Value(
              _str(payload, 'base_unit') ?? existing?.baseUnit ?? 'piece',
            ),
            mrp: Value(_str(payload, 'mrp') ?? existing?.mrp),
            isMrpOnly: Value(
              _bool(payload, 'is_mrp_only') ?? existing?.isMrpOnly ?? false,
            ),
            marketPrice:
                Value(_str(payload, 'market_price') ?? existing?.marketPrice),
            salePrice: Value(
              _str(payload, 'sale_price') ?? existing?.salePrice ?? '0',
            ),
            purchasePrice: Value(
              _str(payload, 'purchase_price') ?? existing?.purchasePrice ?? '0',
            ),
            reorderLevel:
                Value(_str(payload, 'reorder_level') ?? existing?.reorderLevel),
            defaultTaxRate: Value(
              _str(payload, 'default_tax_rate') ?? existing?.defaultTaxRate,
            ),
            primaryImageUrl: Value(
              _str(payload, 'primary_image_url') ?? existing?.primaryImageUrl,
            ),
            syncVersion: Value(syncVersion),
            createdAt: (existing?.createdAt ?? updatedAt).toUtc(),
            updatedAt: updatedAt.toUtc(),
            isDeleted: const Value(false),
            deletedAt: const Value(null),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> updateAckMeta({
    required String entityId,
    required int syncVersion,
    required DateTime updatedAt,
    String? deviceId,
  }) {
    return (_db.update(_db.itemsLocal)..where((t) => t.id.equals(entityId)))
        .write(
      ItemsLocalCompanion(
        syncVersion: Value(syncVersion),
        updatedAt: Value(updatedAt.toUtc()),
        deviceId: deviceId == null ? const Value.absent() : Value(deviceId),
      ),
    );
  }

  static String? _str(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value == null) return null;
    return value.toString();
  }

  static String? _keywords(Map<String, dynamic>? payload) {
    final value = payload?['search_keywords'];
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).where((s) => s.isNotEmpty).join(' ');
    }
    return value.toString();
  }

  static bool? _bool(Map<String, dynamic>? payload, String key) {
    final value = payload?[key];
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    return null;
  }
}
