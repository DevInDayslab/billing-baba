import 'package:billing_baba/core/database/database.dart';
import 'package:billing_baba/core/sync/models/sync_job.dart';
import 'package:billing_baba/core/sync/queue/sync_queue.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:billing_baba/features/inventory/data/item_local_source.dart';
import 'package:billing_baba/features/inventory/models/dto/item_dto.dart';
import 'package:billing_baba/features/inventory/models/dto/pagination_meta_dto.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/requests/item_requests.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _itemsEntity = 'items';

/// Local-first item master writes + SyncQueue enqueue (Parties pattern).
class ItemMasterRepository {
  ItemMasterRepository({
    required this._local,
    required this._syncQueue,
    required this._remote,
    required this._businessIdReader,
    this._deviceIdReader,
  });

  final ItemLocalSource _local;
  final SyncQueue _syncQueue;
  final InventoryRemoteDataSource _remote;
  final String Function() _businessIdReader;
  final String? Function()? _deviceIdReader;

  ItemLocalSource get local => _local;

  String _requireBusinessId() {
    final id = _businessIdReader().trim();
    if (id.isEmpty) {
      throw StateError('No business selected for item operations');
    }
    return id;
  }

  Future<PaginatedItemsDto> list(ItemListQuery query) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    final filter = (
      searchQuery: query.q,
      categoryId: query.categoryId,
      brandId: query.brandId,
      itemType: query.type == null
          ? null
          : (query.type == ItemType.service ? 'service' : 'product'),
    );
    final total = await _local.countActiveFiltered(
      businessId,
      filter: filter,
    );
    final start = (query.page - 1) * query.limit;
    final pageItems = await _local.listActive(
      businessId,
      filter: filter,
      limit: query.limit,
      offset: start,
    );
    return PaginatedItemsDto(
      items: pageItems,
      meta: PaginationMetaDto(
        page: query.page,
        limit: query.limit,
        total: total,
      ),
    );
  }

  ItemLocalFilter _toLocalFilter({
    String? searchQuery,
    ItemType? type,
    String? categoryId,
    String? brandId,
  }) {
    return (
      searchQuery: searchQuery,
      categoryId: categoryId,
      brandId: brandId,
      itemType: type == null
          ? null
          : (type == ItemType.service ? 'service' : 'product'),
    );
  }

  Future<int> countActive({
    String? searchQuery,
    ItemType? type,
    String? categoryId,
    String? brandId,
  }) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    return _local.countActiveFiltered(
      businessId,
      filter: _toLocalFilter(
        searchQuery: searchQuery,
        type: type,
        categoryId: categoryId,
        brandId: brandId,
      ),
    );
  }

  Future<List<ItemListDto>> listPage({
    required int limit,
    required int offset,
    String? searchQuery,
    ItemType? type,
    String? categoryId,
    String? brandId,
  }) async {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    return _local.listActive(
      businessId,
      filter: _toLocalFilter(
        searchQuery: searchQuery,
        type: type,
        categoryId: categoryId,
        brandId: brandId,
      ),
      limit: limit,
      offset: offset,
    );
  }

  Stream<List<ItemListDto>> watchPage({
    required int limit,
    required int offset,
    String? searchQuery,
    ItemType? type,
    String? categoryId,
    String? brandId,
  }) async* {
    final businessId = _requireBusinessId();
    await _hydrateIfEmpty(businessId);
    yield* _local.watchActive(
      businessId,
      filter: _toLocalFilter(
        searchQuery: searchQuery,
        type: type,
        categoryId: categoryId,
        brandId: brandId,
      ),
      limit: limit,
      offset: offset,
    );
  }

  Future<ItemDetailDto?> getActive(String id) async {
    final local = await _local.getActiveDetail(id);
    if (local != null) return local;
    try {
      final remote = await _remote.getItem(id);
      final businessId = _requireBusinessId();
      await _local.upsertFromDetailDto(businessId, remote);
      return remote;
    } on Object {
      return null;
    }
  }

  Future<ItemDetailDto> create(CreateItemRequest request) async {
    final businessId = _requireBusinessId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final row = _rowFromCreate(request);
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      syncVersion: 0,
      createdAt: now,
      updatedAt: now,
      deviceId: _deviceIdReader?.call(),
      name: row.name,
      shortName: row.shortName,
      alias: row.alias,
      searchKeywords: row.searchKeywords,
      description: row.description,
      itemType: row.itemType,
      hasStockTracking: row.hasStockTracking,
      categoryId: row.categoryId,
      brandId: row.brandId,
      hsnCode: row.hsnCode,
      barcode: row.barcode,
      baseUnit: row.baseUnit,
      mrp: row.mrp,
      isMrpOnly: row.isMrpOnly,
      marketPrice: row.marketPrice,
      salePrice: row.salePrice,
      purchasePrice: row.purchasePrice,
      reorderLevel: row.reorderLevel,
      defaultTaxRate: row.defaultTaxRate,
      primaryImageUrl: row.primaryImageUrl,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _itemsEntity,
      entityId: id,
      operation: SyncQueueOperation.create,
      payload: _domainPayload(row),
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDetail(id))!;
  }

  Future<ItemDetailDto> update(String id, UpdateItemRequest request) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) {
      throw StateError('Item not found locally');
    }
    final now = DateTime.now().toUtc();
    final baseVersion = existing.syncVersion;
    final merged = _mergeUpdate(existing, request);
    await _local.upsertRow(
      id: id,
      businessId: businessId,
      syncVersion: baseVersion,
      createdAt: existing.createdAt,
      updatedAt: now,
      deviceId: _deviceIdReader?.call() ?? existing.deviceId,
      name: merged.name,
      shortName: merged.shortName,
      alias: merged.alias,
      searchKeywords: merged.searchKeywords,
      description: merged.description,
      itemType: merged.itemType,
      hasStockTracking: merged.hasStockTracking,
      categoryId: merged.categoryId,
      brandId: merged.brandId,
      hsnCode: merged.hsnCode,
      barcode: merged.barcode,
      baseUnit: merged.baseUnit,
      mrp: merged.mrp,
      isMrpOnly: merged.isMrpOnly,
      marketPrice: merged.marketPrice,
      salePrice: merged.salePrice,
      purchasePrice: merged.purchasePrice,
      reorderLevel: merged.reorderLevel,
      defaultTaxRate: merged.defaultTaxRate,
      primaryImageUrl: merged.primaryImageUrl,
    );
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _itemsEntity,
      entityId: id,
      operation: SyncQueueOperation.update,
      payload: _domainPayload(merged),
      baseSyncVersion: baseVersion,
      clientUpdatedAt: now,
    );
    return (await _local.getActiveDetail(id))!;
  }

  Future<void> softDelete(String id) async {
    final businessId = _requireBusinessId();
    final existing = await _local.getById(id);
    if (existing == null || existing.isDeleted) return;
    final now = DateTime.now().toUtc();
    await _local.softDelete(id: id, deletedAt: now);
    await _syncQueue.enqueueRowMutation(
      businessId: businessId,
      deviceId: _deviceIdReader?.call(),
      entityType: _itemsEntity,
      entityId: id,
      operation: SyncQueueOperation.delete,
      payload: const {},
      baseSyncVersion: existing.syncVersion,
      clientUpdatedAt: now,
    );
  }

  Future<void> _hydrateIfEmpty(String businessId) async {
    final count = await _local.countActive(businessId);
    if (count > 0) return;
    try {
      var page = 1;
      while (true) {
        final response = await _remote.listItems(
          ItemListQuery(page: page, limit: 100),
        );
        for (final listDto in response.items) {
          await _local.upsertFromDetailDto(
            businessId,
            ItemDetailDto(
              id: listDto.id,
              name: listDto.name,
              itemType: listDto.itemType,
              hasStockTracking: listDto.hasStockTracking,
              baseUnit: listDto.baseUnit,
              salePrice: listDto.salePrice,
              purchasePrice: listDto.purchasePrice,
              createdAt: listDto.createdAt,
              updatedAt: listDto.updatedAt,
              shortName: listDto.shortName,
              alias: listDto.alias,
              searchKeywords: listDto.searchKeywords,
              defaultTaxRate: listDto.defaultTaxRate,
              description: listDto.description,
              categoryId: listDto.categoryId,
              brandId: listDto.brandId,
              hsnCode: listDto.hsnCode,
              barcode: listDto.barcode,
              mrp: listDto.mrp,
              marketPrice: listDto.marketPrice,
              reorderLevel: listDto.reorderLevel,
              primaryImageUrl: listDto.primaryImageUrl,
            ),
          );
        }
        if (response.items.length < 100) break;
        if (page * 100 >= response.meta.total) break;
        page += 1;
      }
    } on Object {
      // Offline / first launch with empty local — leave empty.
    }
  }

  static _ItemFields _rowFromCreate(CreateItemRequest request) {
    return _ItemFields(
      name: request.name.trim(),
      shortName: _emptyToNull(request.shortName),
      alias: _emptyToNull(request.alias),
      searchKeywords:
          request.searchKeywords == null || request.searchKeywords!.isEmpty
          ? null
          : request.searchKeywords!.join(' '),
      description: _emptyToNull(request.description),
      itemType: request.itemType,
      hasStockTracking: request.hasStockTracking,
      categoryId: request.categoryId,
      brandId: request.brandId,
      hsnCode: _emptyToNull(request.hsnCode),
      barcode: _emptyToNull(request.barcode),
      baseUnit: request.baseUnit,
      mrp: request.mrp,
      marketPrice: request.marketPrice,
      salePrice: request.salePrice,
      purchasePrice: request.purchasePrice,
      reorderLevel: request.reorderLevel,
      defaultTaxRate: request.defaultTaxRate,
      primaryImageUrl: request.primaryImageUrl,
    );
  }

  static _ItemFields _mergeUpdate(
    ItemTableData existing,
    UpdateItemRequest request,
  ) {
    return _ItemFields(
      name: request.name?.trim() ?? existing.name,
      shortName: request.clearShortName
          ? null
          : (request.shortName ?? existing.shortName),
      alias: request.clearAlias ? null : (request.alias ?? existing.alias),
      searchKeywords: request.clearSearchKeywords
          ? null
          : (request.searchKeywords == null
                ? existing.searchKeywords
                : request.searchKeywords!.join(' ')),
      description: request.description ?? existing.description,
      itemType: request.itemType ?? existing.itemType,
      hasStockTracking: request.hasStockTracking ?? existing.hasStockTracking,
      categoryId: request.clearCategory
          ? null
          : (request.categoryId ?? existing.categoryId),
      brandId: request.clearBrand
          ? null
          : (request.brandId ?? existing.brandId),
      hsnCode: request.hsnCode ?? existing.hsnCode,
      barcode: request.barcode ?? existing.barcode,
      baseUnit: request.baseUnit ?? existing.baseUnit,
      mrp: request.mrp ?? existing.mrp,
      isMrpOnly: existing.isMrpOnly,
      marketPrice: request.marketPrice ?? existing.marketPrice,
      salePrice: request.salePrice ?? existing.salePrice,
      purchasePrice: request.purchasePrice ?? existing.purchasePrice,
      reorderLevel: request.reorderLevel ?? existing.reorderLevel,
      defaultTaxRate: request.clearDefaultTaxRate
          ? null
          : (request.defaultTaxRate ?? existing.defaultTaxRate),
      primaryImageUrl: request.primaryImageUrl ?? existing.primaryImageUrl,
    );
  }

  static Map<String, dynamic> _domainPayload(_ItemFields row) {
    return {
      'name': row.name,
      'short_name': row.shortName,
      'alias': row.alias,
      'search_keywords': row.searchKeywords,
      'description': row.description,
      'item_type': row.itemType,
      'has_stock_tracking': row.hasStockTracking,
      'category_id': row.categoryId,
      'brand_id': row.brandId,
      'hsn_code': row.hsnCode,
      'barcode': row.barcode,
      'base_unit': row.baseUnit,
      'mrp': row.mrp,
      'is_mrp_only': row.isMrpOnly,
      'market_price': row.marketPrice,
      'sale_price': row.salePrice,
      'purchase_price': row.purchasePrice,
      'reorder_level': row.reorderLevel,
      'default_tax_rate': row.defaultTaxRate,
      'primary_image_url': row.primaryImageUrl,
    };
  }

  static String? _emptyToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _ItemFields {
  const _ItemFields({
    required this.name,
    required this.itemType,
    required this.hasStockTracking,
    required this.baseUnit,
    required this.salePrice,
    required this.purchasePrice,
    this.shortName,
    this.alias,
    this.searchKeywords,
    this.description,
    this.categoryId,
    this.brandId,
    this.hsnCode,
    this.barcode,
    this.mrp,
    this.isMrpOnly = false,
    this.marketPrice,
    this.reorderLevel,
    this.defaultTaxRate,
    this.primaryImageUrl,
  });

  final String name;
  final String? shortName;
  final String? alias;
  final String? searchKeywords;
  final String? description;
  final String itemType;
  final bool hasStockTracking;
  final String? categoryId;
  final String? brandId;
  final String? hsnCode;
  final String? barcode;
  final String baseUnit;
  final String? mrp;
  final bool isMrpOnly;
  final String? marketPrice;
  final String salePrice;
  final String purchasePrice;
  final String? reorderLevel;
  final String? defaultTaxRate;
  final String? primaryImageUrl;
}
