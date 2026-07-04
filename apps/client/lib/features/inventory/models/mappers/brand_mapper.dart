import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/models/dto/brand_dto.dart';

abstract final class BrandMapper {
  static BrandModel fromDto(BrandDto dto) {
    return BrandModel(
      id: dto.id,
      name: dto.name,
      itemCount: dto.itemCount,
    );
  }
}
