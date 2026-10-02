import 'package:billing_baba/features/inventory/models/dto/item_location_dto.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';

abstract final class ItemLocationMapper {
  static ItemLocationModel fromDto(ItemLocationDto dto) {
    return ItemLocationModel(
      id: dto.id,
      itemId: dto.itemId,
      godownId: dto.godownId,
      updatedAt: DateTime.parse(dto.updatedAt),
      rack: dto.rack,
      shelf: dto.shelf,
      photoUrl: dto.photoUrl,
    );
  }
}
