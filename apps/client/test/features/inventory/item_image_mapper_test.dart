import 'package:billing_baba/features/inventory/models/mappers/item_image_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItemImageMapper.fromUploadResult', () {
    test('maps upload complete payload', () {
      final model = ItemImageMapper.fromUploadResult({
        'id': 'img-1',
        'image_url': 'https://cdn.example.com/item.png',
        'sort_order': 2,
        'is_primary': true,
      });

      expect(model.id, 'img-1');
      expect(model.imageUrl, 'https://cdn.example.com/item.png');
      expect(model.sortOrder, 2);
      expect(model.isPrimary, isTrue);
    });
  });
}
