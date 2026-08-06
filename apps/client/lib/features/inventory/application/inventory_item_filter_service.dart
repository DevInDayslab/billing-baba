import 'package:billing_baba/features/inventory/models/inventory_item_filters.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';

abstract final class InventoryItemFilterService {
  static bool matches(
    InventoryItem item, {
    required InventoryItemFiltersState filters,
  }) {
    if (!filters.hasActiveFilters) return true;

    for (final option in filters.selected) {
      if (!_matchesOption(item, option)) return false;
    }

    if (filters.brandIds.isNotEmpty) {
      final brandId = item.brandId;
      if (brandId == null || !filters.brandIds.contains(brandId)) {
        return false;
      }
    }

    if (filters.categoryIds.isNotEmpty) {
      final categoryId = item.categoryId;
      if (categoryId == null || !filters.categoryIds.contains(categoryId)) {
        return false;
      }
    }

    return true;
  }

  static bool _matchesOption(
    InventoryItem item,
    InventoryItemFilterOption option,
  ) {
    return switch (option) {
      InventoryItemFilterOption.active => _isActive(item),
      InventoryItemFilterOption.inactive => !_isActive(item),
      InventoryItemFilterOption.showRawMaterialsOnly => item.isRawMaterial,
      InventoryItemFilterOption.hideRawMaterials => !item.isRawMaterial,
    };
  }

  static bool _isActive(InventoryItem item) {
    if (item.type == ItemType.service) return true;
    final quantity = item.quantity;
    return quantity == null || quantity > 0;
  }
}
