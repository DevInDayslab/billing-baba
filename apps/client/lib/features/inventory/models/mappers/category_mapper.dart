import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/dto/category_dto.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';

abstract final class CategoryMapper {
  static InventoryCategory fromDto(CategoryDto dto) {
    return InventoryCategory(
      id: dto.id,
      name: dto.name,
      itemCount: dto.itemCount,
    );
  }

  static InventoryCategory uncategorized({int itemCount = 0}) {
    return InventoryCategory(
      id: uncategorizedCategoryId,
      name: 'Uncategorized',
      itemCount: itemCount,
      isUncategorized: true,
    );
  }

  /// Keeps category badges aligned with the loaded item catalog.
  static List<InventoryCategory> withSyncedItemCounts({
    required List<InventoryCategory> categories,
    required List<InventoryItem> items,
  }) {
    final countsByCategory = <String, int>{};
    for (final item in items) {
      final categoryId = item.categoryId ?? uncategorizedCategoryId;
      countsByCategory[categoryId] = (countsByCategory[categoryId] ?? 0) + 1;
    }

    return [
      uncategorized(itemCount: countsByCategory[uncategorizedCategoryId] ?? 0),
      for (final category in categories.where((entry) => !entry.isUncategorized))
        InventoryCategory(
          id: category.id,
          name: category.name,
          itemCount: countsByCategory[category.id] ?? 0,
        ),
    ];
  }

  static String? toApiCategoryId(String? categoryId) {
    if (categoryId == null || categoryId == uncategorizedCategoryId) {
      return null;
    }
    return categoryId;
  }

  static String fromApiCategoryId(String? categoryId) {
    return categoryId ?? uncategorizedCategoryId;
  }
}
