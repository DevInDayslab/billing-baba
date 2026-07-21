import 'package:billing_baba/features/inventory/models/dto/item_summary_dto.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/tier_price_model.dart';

abstract final class ItemImageMapper {
  static ItemImageModel fromDto(ItemImageDto dto) {
    return ItemImageModel(
      id: dto.id,
      imageUrl: dto.imageUrl,
      thumbnailUrl: dto.thumbnailUrl,
      mediumUrl: dto.mediumUrl,
      mediaAssetId: dto.mediaAssetId,
      sortOrder: dto.sortOrder,
      isPrimary: dto.isPrimary,
    );
  }

  static ItemImageModel fromUploadResult(Map<String, dynamic> result) {
    return ItemImageModel(
      id: result['id'] as String,
      imageUrl: result['image_url'] as String,
      thumbnailUrl: result['thumbnail_url'] as String?,
      mediumUrl: result['medium_url'] as String?,
      mediaAssetId: result['media_asset_id'] as String?,
      sortOrder: (result['sort_order'] as num?)?.toInt() ?? 0,
      isPrimary: result['is_primary'] as bool? ?? false,
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
