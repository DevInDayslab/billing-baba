import 'dart:async';

import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/application/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/pricing/application/item_api_tier_prices_provider.dart';
import 'package:billing_baba/features/pricing/application/local_item_tier_prices_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'inventory_items_provider.g.dart';

/// Clears cached detail/tier data for a single item after mutations.
///
/// Deferred to the next microtask so provider invalidation does not run while
/// the inventory detail panel (and its transactions table) is rebuilding.
void invalidateItemCaches(
  Ref ref,
  String itemId, {
  bool refreshDashboard = false,
}) {
  unawaited(
    Future.microtask(() {
      if (!ref.mounted) return;
      ref
        ..invalidate(productDetailProvider(itemId))
        ..invalidate(itemTierPricesProvider(itemId))
        ..invalidate(itemStockLevelsProvider(itemId))
        ..invalidate(productTransactionsProvider(itemId));
      ref.read(itemApiTierPricesProvider.notifier).removeItem(itemId);
      if (refreshDashboard) {
        invalidateDashboard(ref);
      }
    }),
  );
}

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
  final query = searchQuery?.trim();
  if (query != null && query.isNotEmpty) {
    final engine = InventorySearchEngine.build(
      items: items.map(
        InventorySearchableFields.fromInventoryItem,
      ),
    );
    items = engine.searchItems(items, query: query);
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
  Future<void> _addItemTail = Future.value();

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
    final previous = state.value ?? const <InventoryItem>[];
    state = await AsyncValue.guard(() async {
      try {
        final service = await ref.read(inventoryServiceProvider.future);
        final fetched = await _fetchItemsWithCatalogFallback(
          service,
          searchQuery: searchQuery,
          type: type,
          categoryId: categoryId,
        );
        return mergeFetchedWithPendingLocalInventoryItems(fetched, previous);
      } catch (_) {
        return mergeFetchedWithPendingLocalInventoryItems(
          _catalogItems(
            searchQuery: searchQuery,
            type: type,
            categoryId: categoryId,
          ),
          previous,
        );
      }
    });
  }

  Future<T> _withAddItemLock<T>(Future<T> Function() action) {
    final previous = _addItemTail;
    final gate = Completer<void>();
    _addItemTail = gate.future;
    return previous.then((_) async {
      try {
        return await action();
      } finally {
        gate.complete();
      }
    });
  }

  void _migrateReconciledLocalTierPrices(
    InventoryItem local,
    InventoryItem server,
  ) {
    if (!isPendingLocalInventoryItemId(local.id)) return;
    final tiers = ref.read(localItemTierPricesProvider)[local.id];
    if (tiers == null || tiers.isEmpty) return;
    ref
        .read(localItemTierPricesProvider.notifier)
      ..setTierPrices(server.id, tiers)
      ..removeItem(local.id);
  }

  Future<InventoryItem?> addItemFromForm(AddItemFormState form) {
    return _withAddItemLock(() => _addItemFromFormImpl(form));
  }

  Future<InventoryItem?> _addItemFromFormImpl(AddItemFormState form) async {
    final InventoryItem item;
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final units = await ref.read(inventoryUnitsProvider.future);
      item = await service.createItemFromForm(form, units);
    } on ApiValidationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } on InventoryOfflineException {
      return _addLocalItemFromForm(form);
    } catch (error) {
      throw InventoryException(InventoryErrorMapper.messageForSaveItem(error));
    }

    final current = state.value ?? [];
    for (final existing in current) {
      if (inventoryItemsReconcile(existing, item)) {
        _migrateReconciledLocalTierPrices(existing, item);
      }
    }
    final withoutReconciledLocals = removeReconciledLocalInventoryItems(
      current,
      item,
    );
    state = AsyncData(
      upsertInventoryItemById(withoutReconciledLocals, item),
    );

    try {
      await refreshAfterItemMutation(ref);
    } on Object {
      // Item is already saved and upserted; refresh is best-effort.
    }

    final refreshed = state.value ?? [];
    state = AsyncData(upsertInventoryItemById(refreshed, item));
    return item;
  }

  InventoryItem _addLocalItemFromForm(AddItemFormState form) {
    final units =
        ref.read(inventoryUnitsProvider).value ?? InventoryCatalog.units;
    final localItem = _itemFromForm(form, units);
    final current = state.value ?? [];
    state = AsyncData(upsertInventoryItemById(current, localItem));
    return localItem;
  }

  Future<InventoryItem?> updateItemFromForm(
    String itemId,
    AddItemFormState form, {
    double? initialOpeningQty,
  }) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final units = await ref.read(inventoryUnitsProvider.future);
      final item = await service.updateItemFromForm(
        itemId,
        form,
        units,
        initialOpeningQty: initialOpeningQty,
      );
      final current = state.value ?? [];
      state = AsyncData([
        for (final existing in current)
          if (existing.id == itemId) item else existing,
      ]);
      invalidateItemCaches(ref, itemId, refreshDashboard: true);
      await refresh();
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
      invalidateItemCaches(ref, id, refreshDashboard: true);
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
      await refreshAfterItemMutation(ref);
      return null;
    } on InventoryException catch (error) {
      return error.message;
    } catch (error) {
      return InventoryErrorMapper.messageFor(error);
    }
  }

  Future<void> refreshAfterStockAdjustment(String itemId) async {
    await refreshAfterItemMutation(
      ref,
      context: (partyId: null, itemIds: [itemId]),
    );
  }

  /// Keeps list/POS catalog in sync after gallery uploads without a full refetch.
  void patchItemPrimaryImageUrl(String itemId, String? primaryImageUrl) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData([
      for (final item in current)
        if (item.id == itemId)
          item.copyWith(
            primaryImageUrl: primaryImageUrl ?? '',
          )
        else
          item,
    ]);
  }
}
