import 'package:billing_baba/features/inventory/models/dto/item_location_history_dto.dart';
import 'package:billing_baba/features/inventory/models/item_location_history_model.dart';

abstract final class ItemLocationHistoryMapper {
  static ItemLocationHistoryModel fromDto(ItemLocationHistoryDto dto) {
    return ItemLocationHistoryModel(
      id: dto.id,
      itemLocationId: dto.itemLocationId,
      itemId: dto.itemId,
      createdAt: DateTime.parse(dto.createdAt),
      rack: dto.rack,
      shelf: dto.shelf,
      photoUrl: dto.photoUrl,
      photoMediaAssetId: dto.photoMediaAssetId,
      employeeLabel: dto.employeeLabel,
      changedBy: dto.changedBy,
    );
  }
}
