import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final inventoryCategoriesProvider =
    NotifierProvider<InventoryCategories, List<InventoryCategory>>(
      InventoryCategories.new,
    );

class AddCategoryResult {
  const AddCategoryResult({this.category, this.error});

  final InventoryCategory? category;
  final String? error;

  bool get isSuccess => category != null;
}

class InventoryCategories extends Notifier<List<InventoryCategory>> {
  @override
  List<InventoryCategory> build() => List.of(InventoryCatalog.categories);

  AddCategoryResult addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const AddCategoryResult(error: 'Category name is required');
    }

    final normalized = trimmed.toLowerCase();
    final exists = state.any(
      (category) =>
          !category.isUncategorized &&
          category.name.toLowerCase() == normalized,
    );
    if (exists) {
      return const AddCategoryResult(
        error: 'A category with this name already exists',
      );
    }

    final category = InventoryCategory(
      id: 'category-${_uuid.v4()}',
      name: trimmed,
    );
    state = [...state, category];
    return AddCategoryResult(category: category);
  }
}
