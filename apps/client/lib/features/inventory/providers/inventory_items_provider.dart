import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_units_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_items_provider.g.dart';

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
    final service = await ref.watch(inventoryServiceProvider.future);
    return service.fetchItems();
  }

  Future<void> refresh({
    String? searchQuery,
    ItemType? type,
    String? categoryId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(inventoryServiceProvider.future);
      return service.fetchItems(
        searchQuery: searchQuery,
        type: type,
        categoryId: categoryId,
      );
    });
  }

  Future<InventoryItem?> addItemFromForm(AddItemFormState form) async {
    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final units = await ref.read(inventoryUnitsProvider.future);
      final item = await service.createItemFromForm(form, units);
      final current = state.value ?? [];
      state = AsyncData([...current, item]);
      return item;
    } on ApiValidationException {
      rethrow;
    } on InventoryException {
      rethrow;
    } catch (error) {
      throw InventoryException(InventoryErrorMapper.messageFor(error));
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
