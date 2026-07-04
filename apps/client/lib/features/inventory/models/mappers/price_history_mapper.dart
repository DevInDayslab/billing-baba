import 'package:billing_baba/features/inventory/models/dto/price_history_dto.dart';
import 'package:billing_baba/features/inventory/models/price_history_model.dart';

abstract final class PriceHistoryMapper {
  static PriceHistoryModel fromDto(PriceHistoryDto dto) {
    return PriceHistoryModel(
      id: dto.id,
      itemId: dto.itemId,
      itemName: dto.itemName,
      price: double.tryParse(dto.price) ?? 0,
      pricingTier: dto.pricingTier,
      changedBy: dto.changedBy,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
    );
  }
}
