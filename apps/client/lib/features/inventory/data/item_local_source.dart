import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:drift/drift.dart';

/// Drift-backed local store for item masters. Does not enqueue SyncJobs.
class ItemLocalSource {
  ItemLocalSource(this._db);

  final AppDatabase _db;

  Future<int> countActive(String businessId) async {
    final rows = await (_db.select(_db.itemsLocal)
          ..where(
            (t) =>
                t.businessId.equals(businessId) & t.isDeleted.equals(false),
          ))
        .get();
    return rows.length;
  }

  Future<List<ItemListDto>> listActive(
    String businessId, {
    String? searchQuery,
    String? categoryId,
    String? brandId,
    String? itemType,
  }) async {
    final query = _db.select(_db.itemsLocal)
      ..where(
        (t) => t.businessId.equals(businessId) & t.isDeleted.equals(false),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    final q = searchQuery?.trim().toLowerCase();
    var filtered = rows;
    if (q != null && q.isNotEmpty) {
      filtered = filtered.where((r) {
        final hay =
            '${r.name} ${r.barcode ?? ''} ${r.hsnCode ?? ''} ${r.alias ?? ''}'
                .toLowerCase();
        return hay.contains(q);
      }).toList();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      filtered = filtered.where((r) => r.categoryId == categoryId).toList();
    }
    if (brandId != null && brandId.isNotEmpty) {
      filtered = filtered.where((r) => r.brandId == brandId).toList();
    }
    if (itemType != null && itemType.isNotEmpty) {
      filtered = filtered.where((r) => r.itemType == itemType).toList();
    }
    return filtered.map(_toListDto).toList();
  }

  Future<ItemTableData?> getById(String id) {
    return (_db.select(_db.itemsLocal)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<ItemDetailDto?> getActiveDetail(String id) async {
    final row = await getById(id);
    if (row == null || row.isDeleted) return null;
    return _toDetailDto(row);
  }

  Future<void> upsertRow({
    required String id,
    required String businessId,
    required String name,
    required int syncVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? shortName,
    String? alias,
    String? searchKeywords,
    String? description,
    String itemType = 'product',
    bool hasStockTracking = true,
    String? categoryId,
    String? brandId,
    String? hsnCode,
    String? barcode,
    String baseUnit = 'piece',
    String? mrp,
    bool isMrpOnly = false,
    String? marketPrice,
    String salePrice = '0',
    String purchasePrice = '0',
    String? reorderLevel,
    String? defaultTaxRate,
    String? primaryImageUrl,
    DateTime? deletedAt,
    bool isDeleted = false,
    String? deviceId,
  }) {
    return _db.into(_db.itemsLocal).insertOnConflictUpdate(
          ItemsLocalCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            shortName: Value(shortName),
            alias: Value(alias),
            searchKeywords: Value(searchKeywords),
            description: Value(description),
            itemType: Value(itemType),
            hasStockTracking: Value(hasStockTracking),
            categoryId: Value(categoryId),
            brandId: Value(brandId),
            hsnCode: Value(hsnCode),
            barcode: Value(barcode),
            baseUnit: Value(baseUnit),
            mrp: Value(mrp),
            isMrpOnly: Value(isMrpOnly),
            marketPrice: Value(marketPrice),
            salePrice: Value(salePrice),
            purchasePrice: Value(purchasePrice),
            reorderLevel: Value(reorderLevel),
            defaultTaxRate: Value(defaultTaxRate),
            primaryImageUrl: Value(primaryImageUrl),
            syncVersion: Value(syncVersion),
            createdAt: createdAt.toUtc(),
            updatedAt: updatedAt.toUtc(),
            deletedAt: Value(deletedAt?.toUtc()),
            isDeleted: Value(isDeleted),
            deviceId: Value(deviceId),
          ),
        );
  }

  Future<void> upsertFromDetailDto(String businessId, ItemDetailDto dto) {
    final created =
        DateTime.tryParse(dto.createdAt)?.toUtc() ?? DateTime.now().toUtc();
    final updated =
        DateTime.tryParse(dto.updatedAt)?.toUtc() ?? created;
    return upsertRow(
      id: dto.id,
      businessId: businessId,
      name: dto.name,
      shortName: dto.shortName,
      alias: dto.alias,
      searchKeywords: dto.searchKeywords.isEmpty
          ? null
          : dto.searchKeywords.join(' '),
      description: dto.description,
      itemType: dto.itemType,
      hasStockTracking: dto.hasStockTracking,
      categoryId: dto.categoryId,
      brandId: dto.brandId,
      hsnCode: dto.hsnCode,
      barcode: dto.barcode,
      baseUnit: dto.baseUnit,
      mrp: dto.mrp,
      marketPrice: dto.marketPrice,
      salePrice: dto.salePrice,
      purchasePrice: dto.purchasePrice,
      reorderLevel: dto.reorderLevel,
      defaultTaxRate: dto.defaultTaxRate,
      primaryImageUrl: dto.primaryImageUrl,
      syncVersion: 1,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Future<void> softDelete({
    required String id,
    required DateTime deletedAt,
  }) {
    return (_db.update(_db.itemsLocal)..where((t) => t.id.equals(id))).write(
      ItemsLocalCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(deletedAt.toUtc()),
        updatedAt: Value(deletedAt.toUtc()),
      ),
    );
  }

  ItemListDto _toListDto(ItemTableData row) {
    return ItemListDto(
      id: row.id,
      name: row.name,
      itemType: row.itemType,
      hasStockTracking: row.hasStockTracking,
      baseUnit: row.baseUnit,
      salePrice: row.salePrice,
      purchasePrice: row.purchasePrice,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
      shortName: row.shortName,
      alias: row.alias,
      searchKeywords: _splitKeywords(row.searchKeywords),
      defaultTaxRate: row.defaultTaxRate,
      description: row.description,
      categoryId: row.categoryId,
      brandId: row.brandId,
      hsnCode: row.hsnCode,
      barcode: row.barcode,
      mrp: row.mrp,
      marketPrice: row.marketPrice,
      reorderLevel: row.reorderLevel,
      primaryImageUrl: row.primaryImageUrl,
    );
  }

  ItemDetailDto _toDetailDto(ItemTableData row) {
    return ItemDetailDto(
      id: row.id,
      name: row.name,
      itemType: row.itemType,
      hasStockTracking: row.hasStockTracking,
      baseUnit: row.baseUnit,
      salePrice: row.salePrice,
      purchasePrice: row.purchasePrice,
      createdAt: row.createdAt.toUtc().toIso8601String(),
      updatedAt: row.updatedAt.toUtc().toIso8601String(),
      shortName: row.shortName,
      alias: row.alias,
      searchKeywords: _splitKeywords(row.searchKeywords),
      defaultTaxRate: row.defaultTaxRate,
      description: row.description,
      categoryId: row.categoryId,
      brandId: row.brandId,
      hsnCode: row.hsnCode,
      barcode: row.barcode,
      mrp: row.mrp,
      marketPrice: row.marketPrice,
      reorderLevel: row.reorderLevel,
      primaryImageUrl: row.primaryImageUrl,
    );
  }

  static List<String> _splitKeywords(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split(RegExp(r'\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}
