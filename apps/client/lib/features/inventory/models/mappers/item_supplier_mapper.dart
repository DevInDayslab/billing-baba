import 'package:billing_baba/features/inventory/models/dto/item_supplier_dto.dart';
import 'package:billing_baba/features/inventory/models/item_supplier_model.dart';

abstract final class ItemSupplierMapper {
  static ItemSupplierModel fromDto(ItemSupplierDto dto) {
    return ItemSupplierModel(
      id: dto.id,
      itemId: dto.itemId,
      partyId: dto.partyId,
      isDefault: dto.isDefault,
      sortOrder: dto.sortOrder,
    );
  }
}
