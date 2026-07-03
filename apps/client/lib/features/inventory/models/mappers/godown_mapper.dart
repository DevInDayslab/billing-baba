import 'package:billing_baba/features/inventory/models/dto/godown_dto.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';

abstract final class GodownMapper {
  static GodownModel fromDto(GodownDto dto) {
    return GodownModel(
      id: dto.id,
      name: dto.name,
      address: dto.address,
      isDefault: dto.isDefault,
      stockItemCount: dto.stockItemCount,
    );
  }
}
