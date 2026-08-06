import 'dart:async';

import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/application/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_item_list_merge.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/application/inventory_units_provider.dart';
import 'package:billing_baba/features/inventory/application/item_tier_prices_provider.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'inventory_items_provider.g.dart';

/// Flat list view of the paginated inventory catalog.
final inventoryItemListProvider = Provider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryItemsProvider).value?.items ?? const [];
});

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
        ..invalidate(itemTierPricesForItemProvider(itemId))
        ..invalidate(itemStockLevelsProvider(itemId))
        ..invalidate(productTransactionsProvider(itemId));
      if (refreshDashboard) {
        invalidateDashboard(ref);
      }
    }),
  );
}

const _uuid = Uuid();

InventoryItemsQuery _currentQuery(Ref ref) {
  return InventoryItemsQuery(
    searchQuery: ref.watch(productBackendSearchProvider),
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
  StreamSubscription<PaginatedInventoryItems>? _watchSub;
  InventoryItemsQuery _query = const InventoryItemsQuery();
  int _loadedCount = InventoryService.inventoryPageSize;

  @override
  Future<PaginatedInventoryItems> build() async {
    ref.onDispose(() => _watchSub?.cancel());
    ref.listen(productBackendSearchProvider, (_, next) {
      unawaited(refresh(searchQuery: next));
    });

    final service = await ref.watch(inventoryServiceProvider.future);
    _query = _currentQuery(ref);
    _loadedCount = InventoryService.inventoryPageSize;
    return _startWatching(service);
  }

  Future<PaginatedInventoryItems> _startWatching(
    InventoryService service,
  ) async {
    _watchSub?.cancel();
    final initial = await service.fetchItemsPage(
      limit: _loadedCount,
      searchQuery: _query.searchQuery,
      type: _query.type,
      categoryId: _query.categoryId,
    );

    _watchSub = service
        .watchItemsPage(
          limit: _loadedCount,
          searchQuery: _query.searchQuery,
          type: _query.type,
          categoryId: _query.categoryId,
        )
        .listen(
          (page) {
            if (!ref.mounted) return;
            final previous = state.value;
            state = AsyncData(
              page.copyWith(
                isLoadingMore: previous?.isLoadingMore ?? false,
              ),
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!ref.mounted) return;
            state = AsyncError(error, stackTrace);
          },
        );

    return initial;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final next = await service.fetchItemsPage(
        offset: current.items.length,
        searchQuery: _query.searchQuery,
        type: _query.type,
        categoryId: _query.categoryId,
      );
      final merged = PaginatedInventoryItems(
        items: [
          ...current.items,
          ...next.items,
        ],
        totalCount: next.totalCount,
        hasMore: current.items.length + next.items.length < next.totalCount,
      );
      _loadedCount = merged.items.length;
      _watchSub?.cancel();
      _watchSub = service
          .watchItemsPage(
            limit: _loadedCount,
            searchQuery: _query.searchQuery,
            type: _query.type,
            categoryId: _query.categoryId,
          )
          .listen(
            (page) {
              if (!ref.mounted) return;
              state = AsyncData(page.copyWith(isLoadingMore: false));
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!ref.mounted) return;
              state = AsyncError(error, stackTrace);
            },
          );
      state = AsyncData(merged);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh({
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) async {
    final previous =
        state.value ??
        const PaginatedInventoryItems(
          items: [],
          totalCount: 0,
          hasMore: false,
        );
    _query = InventoryItemsQuery(
      searchQuery: searchQuery ?? _query.searchQuery,
      type: type ?? _query.type,
      categoryId: categoryId ?? _query.categoryId,
    );
    _loadedCount = InventoryService.inventoryPageSize;

    state = await AsyncValue.guard(() async {
      final service = await ref.read(inventoryServiceProvider.future);
      final fetched = await service.fetchItemsPage(
        limit: _loadedCount,
        searchQuery: _query.searchQuery,
        type: _query.type,
        categoryId: _query.categoryId,
      );
      final mergedItems = mergeFetchedWithPendingLocalInventoryItems(
        fetched.items,
        previous.items,
      );
      final page = fetched.copyWith(items: mergedItems);
      _watchSub?.cancel();
      _watchSub = service
          .watchItemsPage(
            limit: _loadedCount,
            searchQuery: _query.searchQuery,
            type: _query.type,
            categoryId: _query.categoryId,
          )
          .listen(
            (streamPage) {
              if (!ref.mounted) return;
              state = AsyncData(
                streamPage.copyWith(
                  items: mergeFetchedWithPendingLocalInventoryItems(
                    streamPage.items,
                    state.value?.items ?? const [],
                  ),
                ),
              );
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!ref.mounted) return;
              state = AsyncError(error, stackTrace);
            },
          );
      return page;
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
    final tiers = ref.read(itemTierPricesProvider).value?[local.id];
    if (tiers == null || tiers.isEmpty) return;
    unawaited(() async {
      await ref
          .read(itemTierPricesProvider.notifier)
          .setTierPrices(server.id, tiers);
      await ref.read(itemTierPricesProvider.notifier).removeItem(local.id);
    }());
  }

  void _upsertItem(InventoryItem item) {
    final current = state.value;
    if (current == null) return;
    final withoutReconciledLocals = removeReconciledLocalInventoryItems(
      current.items,
      item,
    );
    state = AsyncData(
      current.copyWith(
        items: upsertInventoryItemById(withoutReconciledLocals, item),
      ),
    );
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

    final current = state.value?.items ?? [];
    for (final existing in current) {
      if (inventoryItemsReconcile(existing, item)) {
        _migrateReconciledLocalTierPrices(existing, item);
      }
    }
    _upsertItem(item);

    try {
      await refreshAfterItemMutation(ref);
    } on Object {
      // Item is already saved and upserted; refresh is best-effort.
    }

    _upsertItem(item);
    return item;
  }

  InventoryItem _addLocalItemFromForm(AddItemFormState form) {
    final units =
        ref.read(inventoryUnitsProvider).value ?? InventoryCatalog.units;
    final localItem = _itemFromForm(form, units);
    _upsertItem(localItem);
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
      final current = state.value;
      if (current != null) {
        state = AsyncData(
          current.copyWith(
            items: [
              for (final existing in current.items)
                if (existing.id == itemId) item else existing,
            ],
          ),
        );
      }
      invalidateItemCaches(ref, itemId, refreshDashboard: true);
      await refresh();
      return item;
    } on ApiValidationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } on InventoryOfflineException {
      rethrow;
    } catch (error) {
      throw InventoryException(InventoryErrorMapper.messageFor(error));
    }
  }

  void patchItemQuantity(String itemId, double newQuantity) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final item in current.items)
            if (item.id == itemId)
              item.copyWith(
                quantity: newQuantity,
                stockValue: newQuantity * (item.purchasePrice ?? 0),
              )
            else
              item,
        ],
      ),
    );
  }

  Future<String?> deleteItem(String id) async {
    final previous = state;
    final current = state.value;
    if (current == null) return null;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((item) => item.id != id).toList(),
      ),
    );

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteItem(id);
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

  void patchItemPrimaryImageUrl(String itemId, String? primaryImageUrl) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        items: [
          for (final item in current.items)
            if (item.id == itemId)
              item.copyWith(
                primaryImageUrl: primaryImageUrl ?? '',
              )
            else
              item,
        ],
      ),
    );
  }
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
