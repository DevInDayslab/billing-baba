import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/dto/category_dto.dart';

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
