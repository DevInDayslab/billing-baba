import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/dto/brand_dto.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';

abstract final class BrandMapper {
  static BrandModel fromDto(BrandDto dto) {
    return BrandModel(
      id: dto.id,
      name: dto.name,
      itemCount: dto.itemCount,
    );
  }

  static BrandModel unbranded({int itemCount = 0}) {
    return BrandModel(
      id: unbrandedBrandId,
      name: 'No Brand',
      itemCount: itemCount,
      isUnbranded: true,
    );
  }

  static List<BrandModel> withSyncedItemCounts({
    required List<BrandModel> brands,
    required List<InventoryItem> items,
  }) {
    final countsByBrand = <String, int>{};
    for (final item in items) {
      final brandId = item.brandId ?? unbrandedBrandId;
      countsByBrand[brandId] = (countsByBrand[brandId] ?? 0) + 1;
    }

    return [
      unbranded(itemCount: countsByBrand[unbrandedBrandId] ?? 0),
      for (final brand in brands.where((entry) => !entry.isUnbranded))
        BrandModel(
          id: brand.id,
          name: brand.name,
          itemCount: countsByBrand[brand.id] ?? 0,
        ),
    ];
  }

  static String? toApiBrandId(String? brandId) {
    if (brandId == null || brandId == unbrandedBrandId) {
      return null;
    }
    return brandId;
  }
}
