import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/providers/data_refresh.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_categories_provider.g.dart';

final categoryBackendSearchProvider =
    NotifierProvider<CategoryBackendSearch, String>(CategoryBackendSearch.new);

class CategoryBackendSearch extends Notifier<String> {
  @override
  String build() => '';

  String get query => state;
  set query(String value) => state = value;
}

class AddCategoryResult {
  const AddCategoryResult({this.category, this.error});

  final InventoryCategory? category;
  final String? error;

  bool get isSuccess => category != null;
}

@Riverpod(keepAlive: true)
class InventoryCategories extends _$InventoryCategories {
  @override
  Future<List<InventoryCategory>> build() async {
    final service = await ref.watch(inventoryServiceProvider.future);
    return service.fetchCategories();
  }

  Future<void> refresh({String? searchQuery}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = await ref.read(inventoryServiceProvider.future);
      return service.fetchCategories(
        searchQuery: searchQuery ?? ref.read(categoryBackendSearchProvider),
      );
    });
  }

  Future<AddCategoryResult> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const AddCategoryResult(error: 'Category name is required');
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final category = await service.createCategory(trimmed);
      await refresh();
      return AddCategoryResult(category: category);
    } on ApiValidationException catch (error) {
      return AddCategoryResult(
        error: error.fieldErrors['name'] ?? error.message,
      );
    } on InventoryException catch (error) {
      return AddCategoryResult(error: error.message);
    } catch (error) {
      return AddCategoryResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<AddCategoryResult> updateCategory(String id, String name) async {
    if (id == uncategorizedCategoryId) {
      return const AddCategoryResult(
        error: 'Uncategorized cannot be renamed.',
      );
    }

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const AddCategoryResult(error: 'Category name is required');
    }

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      final category = await service.updateCategory(id, trimmed);
      await refresh();
      return AddCategoryResult(category: category);
    } on ApiValidationException catch (error) {
      return AddCategoryResult(
        error: error.fieldErrors['name'] ?? error.message,
      );
    } on InventoryException catch (error) {
      return AddCategoryResult(error: error.message);
    } catch (error) {
      return AddCategoryResult(error: InventoryErrorMapper.messageFor(error));
    }
  }

  Future<String?> deleteCategory(String id) async {
    if (id == uncategorizedCategoryId) {
      return 'Uncategorized cannot be deleted.';
    }

    final previous = state;
    final current = state.value ?? [];
    state = AsyncData(current.where((category) => category.id != id).toList());

    try {
      final service = await ref.read(inventoryServiceProvider.future);
      await service.deleteCategory(id);
      await refresh();
      invalidateInventoryLists(ref);
      invalidateDashboard(ref);
      return null;
    } on InventoryException catch (error) {
      state = previous;
      return error.message;
    } catch (error) {
      state = previous;
      return InventoryErrorMapper.messageFor(error);
    }
  }
}
