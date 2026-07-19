import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/pos/repositories/api_pos_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps inventory primary image URL to POS item', () {
    final posItem = mapInventoryItemToPosItem(
      const InventoryItem(
        id: 'item-1',
        name: 'Widget',
        type: ItemType.product,
        salePrice: 99,
        primaryImageUrl: 'https://cdn.example.com/widget.png',
        availableForSale: 12,
        barcode: 'SKU-1',
      ),
    );

    expect(posItem.imageUrl, 'https://cdn.example.com/widget.png');
    expect(posItem.stock, 12);
    expect(posItem.sku, 'SKU-1');
  });
}
