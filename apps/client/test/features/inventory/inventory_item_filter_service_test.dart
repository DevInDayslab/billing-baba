import 'package:billing_baba/features/inventory/application/inventory_item_filter_service.dart';
import 'package:billing_baba/features/inventory/models/inventory_item_filters.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const item = InventoryItem(
    id: '1',
    name: 'Widget',
    type: ItemType.product,
    quantity: 5,
    brandId: 'brand-a',
    categoryId: 'cat-a',
  );

  test('matches brand and category filters', () {
    expect(
      InventoryItemFilterService.matches(
        item,
        filters: const InventoryItemFiltersState(brandIds: {'brand-a'}),
      ),
      isTrue,
    );
    expect(
      InventoryItemFilterService.matches(
        item,
        filters: const InventoryItemFiltersState(brandIds: {'brand-b'}),
      ),
      isFalse,
    );
    expect(
      InventoryItemFilterService.matches(
        item,
        filters: const InventoryItemFiltersState(categoryIds: {'cat-a'}),
      ),
      isTrue,
    );
  });

  test('combines status and brand filters', () {
    expect(
      InventoryItemFilterService.matches(
        item,
        filters: const InventoryItemFiltersState(
          selected: {InventoryItemFilterOption.active},
          brandIds: {'brand-a'},
        ),
      ),
      isTrue,
    );
  });
}
