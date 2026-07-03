import 'package:billing_baba/features/inventory/models/dto/item_summary_dto.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';

abstract final class ItemImageMapper {
  static ItemImageModel fromDto(ItemImageDto dto) {
    return ItemImageModel(
      id: dto.id,
      imageUrl: dto.imageUrl,
      sortOrder: dto.sortOrder,
      isPrimary: dto.isPrimary,
    );
  }
}

abstract final class TierPriceMapper {
  static TierPriceModel fromDto(TierPriceDto dto) {
    return TierPriceModel(
      pricingTier: dto.pricingTier,
      price: double.tryParse(dto.price) ?? 0,
    );
  }
}
