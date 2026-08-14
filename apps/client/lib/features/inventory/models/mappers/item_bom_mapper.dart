import 'package:billing_baba/features/inventory/models/dto/item_bom_dto.dart';
import 'package:billing_baba/features/inventory/models/item_bom_model.dart';

abstract final class ItemBomMapper {
  static ItemBomModel fromDto(ItemBomDto dto) {
    return ItemBomModel(
      materials: dto.materials.map(fromMaterialDto).toList(),
      costs: dto.costs.map(fromCostDto).toList(),
    );
  }

  static ItemBomMaterialModel fromMaterialDto(ItemBomMaterialDto dto) {
    return ItemBomMaterialModel(
      id: dto.id,
      itemId: dto.itemId,
      rawItemId: dto.rawItemId,
      qty: _parseDouble(dto.qty),
      unitId: dto.unitId,
      purchasePrice: _parseDouble(dto.purchasePrice),
      sortOrder: dto.sortOrder,
      rawItemName: dto.rawItem?.name ?? '',
      rawItemBaseUnit: dto.rawItem?.baseUnit ?? '',
    );
  }

  static ItemBomCostModel fromCostDto(ItemBomCostDto dto) {
    return ItemBomCostModel(
      id: dto.id,
      itemId: dto.itemId,
      description: dto.description,
      amount: _parseDouble(dto.amount),
      sortOrder: dto.sortOrder,
    );
  }

  static double _parseDouble(String value) => double.tryParse(value) ?? 0;
}
