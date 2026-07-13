import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:billing_baba/features/pricing/providers/local_item_tier_prices_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'inventory_items_provider.g.dart';

const _uuid = Uuid();

List<InventoryItem> _catalogItems({
  String? searchQuery,
  ItemType? type,
  String? categoryId,
}) {
  var items = InventoryCatalog.items;
  if (type != null) {
    items = items.where((item) => item.type == type).toList();
  }
  if (categoryId != null) {
    items = items.where((item) => item.categoryId == categoryId).toList();
  }
  final query = searchQuery?.trim().toLowerCase();
  if (query != null && query.isNotEmpty) {
    items = items
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }
  return items;
}

Future<List<InventoryItem>> _fetchItemsWithCatalogFallback(
  InventoryService service, {
  String? searchQuery,
  ItemType? type,
  String? categoryId,
}) async {
  try {
    final items = await service.fetchItems(
      searchQuery: searchQuery,
      type: type,
      categoryId: categoryId,
    );
    if (items.isNotEmpty) return items;
  } catch (_) {
    // Fall through to local catalog when API is empty or unavailable.
  }
  return _catalogItems(
    searchQuery: searchQuery,
    type: type,
    categoryId: categoryId,
  );
}

InventoryItem _itemFromForm(
  AddItemFormState form,
  List<InventoryUnit> units,
) {
  final unit = units.where((u) => u.id == form.baseUnitId).firstOrNull;
  return InventoryItem(
    id: 'item-local-${_uuid.v4()}',
    name: form.itemName.trim(),
    type: form.itemType,
    salePrice: form.salePrice,
    purchasePrice: form.atPrice,
    quantity: form.openingQty,
    availableForSale: form.openingQty,
    stockValue: form.openingQty * form.atPrice,
    categoryId: form.categoryId,
    hsnCode: form.hsn.isEmpty ? null : form.hsn,
    barcode: form.itemCode.isEmpty ? null : form.itemCode,
    baseUnitShortName: unit?.shortName ?? 'Pcs',
    description: form.description.isEmpty ? null : form.description,
  );
}

final productBackendSearchProvider =
    NotifierProvider<ProductBackendSearch, String>(ProductBackendSearch.new);

final serviceBackendSearchProvider =
    NotifierProvider<ServiceBackendSearch, String>(ServiceBackendSearch.new);

class ProductBackendSearch extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class ServiceBackendSearch extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

@Riverpod(keepAlive: true)
class InventoryItems extends _$InventoryItems {
  @override
  Future<List<InventoryItem>> build() async {
    try {
      final service = await ref.watch(inventoryServiceProvider.future);
      return _fetchItemsWithCatalogFallback(service);
    } catch (_) {
      return _catalogItems();
    }
  }

  Future<void> refresh({
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) async {
    state = await AsyncValue.guard(() async {
      try {
        final service = await ref.read(inventoryServiceProvider.future);
        return _fetchItemsWithCatalogFallback(
          service,
          searchQuery: searchQuery,
          type: type,
          categoryId: categoryId,
        );
      } catch (_) {
        return _catalogItems(
          searchQuery: searchQuery,
          type: type,
          categoryId: categoryId,
        );
      }
    });
  }

  Future<InventoryItem?> addItemFromForm(AddItemFormState form) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final units = await ref.read(inventoryUnitsProvider.future);
      final item = await service.createItemFromForm(form, units);
      final current = state.value ?? [];
      state = AsyncData([...current, item]);
      refreshAfterItemMutation(ref);
      return item;
    } on ApiValidationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (error) {
      // Offline / API unavailable — add to local catalog-backed list.
      final units = ref.read(inventoryUnitsProvider).value ?? InventoryCatalog.units;
      final item = _itemFromForm(form, units);
      final current = state.value ?? [];
      state = AsyncData([...current, item]);
      return item;
    }
  }

  Future<InventoryItem?> updateItemFromForm(
    String itemId,
    AddItemFormState form,
  ) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final units = await ref.read(inventoryUnitsProvider.future);
      final item = await service.updateItemFromForm(itemId, form, units);
      final current = state.value ?? [];
      state = AsyncData([
        for (final existing in current)
          if (existing.id == itemId) item else existing,
      ]);
      return item;
    } on ApiValidationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (error) {
      throw InventoryException(InventoryErrorMapper.messageFor(error));
    }
  }

  Future<String?> deleteItem(String id) async {
    final previous = state;
    final current = state.value ?? [];
    state = AsyncData(current.where((item) => item.id != id).toList());

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteItem(id);
      ref.read(localItemTierPricesProvider.notifier).removeItem(id);
      return null;
    } on InventoryException catch (error) {
      state = previous;
      return error.message;
    } catch (error) {
      state = previous;
      return InventoryErrorMapper.messageFor(error);
    }
  }

  Future<String?> moveItemsToCategory({
    required List<String> itemIds,
    required String categoryId,
    required bool removeFromExistingCategory,
  }) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.moveItemsToCategory(
        itemIds: itemIds,
        categoryId: categoryId,
        removeFromExistingCategory: removeFromExistingCategory,
      );
      await refresh(searchQuery: ref.read(productBackendSearchProvider));
      return null;
    } on InventoryException catch (error) {
      return error.message;
    } catch (error) {
      return InventoryErrorMapper.messageFor(error);
    }
  }
}
