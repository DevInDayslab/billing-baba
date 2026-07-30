import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:collection/collection.dart';

/// POS-facing category chip data derived from inventory categories.
class PosCategoryOption {
  const PosCategoryOption({required this.id, required this.name});

  final String id;
  final String name;
}

/// Maps a single inventory item to the POS view model.
PosItem mapInventoryItemToPosItem(
  InventoryItem item, {
  String categoryName = 'Uncategorized',
}) {
  final stock = InventoryStockCalculator.metricsFromItem(
    item,
  ).availableForSale.round();

  return PosItem(
    id: item.id,
    name: item.name,
    sku: item.barcode ?? item.id,
    categoryId: item.categoryId,
    categoryName: categoryName,
    price: item.salePrice ?? 0,
    mrp: item.mrp,
    stock: stock,
    unit: item.baseUnitShortName ?? 'pcs',
    imageUrl: resolvePosItemImageUrl(item),
    hsnCode: item.hsnCode,
  );
}

/// Uses the primary image from Item Master; list API does not include gallery.
String? resolvePosItemImageUrl(InventoryItem item) {
  final primary = item.primaryImageUrl?.trim();
  if (primary != null && primary.isNotEmpty) return primary;
  return null;
}

/// Picks the display image from a gallery list (primary, else first by sort order).
({String url, String? mediaAssetId})? resolvePosImageFromGallery(
  List<ItemImageModel> images,
) {
  if (images.isEmpty) return null;
  final primary = images.where((image) => image.isPrimary).firstOrNull;
  final image =
      primary ??
      images.sorted((a, b) => a.sortOrder.compareTo(b.sortOrder)).first;
  final url = image.urlForGrid().trim();
  if (url.isEmpty) return null;
  return (url: url, mediaAssetId: image.mediaAssetId);
}

/// Builds POS catalog from the shared inventory list (products only).
List<PosItem> mapInventoryItemsToPosItems(
  Iterable<InventoryItem> items,
  Map<String, String> categoryNamesById,
) {
  return items
      .where((item) => item.type == ItemType.product)
      .map(
        (item) => mapInventoryItemToPosItem(
          item,
          categoryName: categoryNamesById[item.categoryId] ?? 'Uncategorized',
        ),
      )
      .toList();
}

Map<String, String> categoryNamesById(List<InventoryCategory> categories) {
  return {for (final category in categories) category.id: category.name};
}

/// Categories that contain at least one product in the current catalog.
List<PosCategoryOption> posCategoriesForCatalog(
  List<PosItem> catalog,
  List<InventoryCategory> categories,
) {
  final usedIds = catalog
      .map((item) => item.categoryId)
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toSet();

  return categories
      .where((category) => usedIds.contains(category.id))
      .map(
        (category) => PosCategoryOption(id: category.id, name: category.name),
      )
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
}

/// Filters POS catalog using the same search engine as the inventory module.
List<PosItem> filterPosCatalog({
  required List<PosItem> catalog,
  required Iterable<InventoryItem> inventoryItems,
  required InventorySearchEngine searchEngine,
  String searchQuery = '',
  String? categoryId,
  bool inStockOnly = false,
}) {
  final products = inventoryItems.where(
    (item) => item.type == ItemType.product,
  );
  Iterable<PosItem> result = catalog;

  if (categoryId != null && categoryId.isNotEmpty) {
    result = result.where((item) => item.categoryId == categoryId);
  }

  if (inStockOnly) {
    result = result.where((item) => item.stock > 0);
  }

  final query = searchQuery.trim();
  if (query.isEmpty) return result.toList();

  final barcodeMatch = findInventoryItemByBarcodeOrQuery(
    searchEngine,
    products,
    query: query,
  );
  if (barcodeMatch != null) {
    final ids = {barcodeMatch.id};
    return result.where((item) => ids.contains(item.id)).toList();
  }

  final matchedIds = searchInventoryItems(
    searchEngine,
    products,
    query: query,
  ).map((item) => item.id).toSet();

  return result.where((item) => matchedIds.contains(item.id)).toList();
}

/// Resolves the latest POS item snapshot from cached inventory (for cart validation).
PosItem? findLivePosItem({
  required String itemId,
  required List<InventoryItem> inventoryItems,
  required Map<String, String> categoryNamesById,
}) {
  final item = inventoryItems
      .where((candidate) => candidate.id == itemId)
      .firstOrNull;
  if (item == null || item.type != ItemType.product) return null;
  return mapInventoryItemToPosItem(
    item,
    categoryName: categoryNamesById[item.categoryId] ?? 'Uncategorized',
  );
}
