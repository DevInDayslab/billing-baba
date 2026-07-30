import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/add_item_form_mapper.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/mappers/category_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddItemFormMapper', () {
    test('maps brand, godown, and tier prices on create', () {
      const form = AddItemFormState(
        itemName: 'Widget',
        brandId: 'brand-1',
        godownId: 'godown-1',
        salePrice: 100,
        wholesalePrice: 80,
        openingQty: 5,
        location: 'Rack A',
        primaryImageUrl: 'https://example.com/img.jpg',
      );

      final request = AddItemFormMapper.toCreateRequest(
        form,
        baseUnitShortName: 'PCS',
        openingGodownId: 'fallback-godown',
        godownIdForLocation: 'fallback-godown',
      );

      expect(request.brandId, 'brand-1');
      expect(request.openingGodownId, 'godown-1');
      expect(request.location?.godownId, 'godown-1');
      expect(request.location?.rack, 'Rack A');
      expect(request.primaryImageUrl, 'https://example.com/img.jpg');
      expect(request.tierPrices, hasLength(2));
      expect(request.tierPrices.map((t) => t.pricingTier), [
        'tier_1',
        'tier_2',
      ]);
    });

    test('maps brand and image on update', () {
      const form = AddItemFormState(
        itemName: 'Widget',
        brandId: 'brand-2',
        primaryImageUrl: 'https://example.com/new.jpg',
        wholesalePrice: 50,
      );

      final request = AddItemFormMapper.toUpdateRequest(
        form,
        baseUnitShortName: 'PCS',
      );

      expect(request.brandId, 'brand-2');
      expect(request.primaryImageUrl, 'https://example.com/new.jpg');

      final tiers = AddItemFormMapper.tierPricesForUpsert(form);
      expect(tiers, hasLength(1));
      expect(tiers.first.pricingTier, 'tier_2');
    });

    test('maps opening stock on update when quantity changed', () {
      const form = AddItemFormState(
        itemName: 'Hairpin',
        openingQty: 11,
        atPrice: 100,
        godownId: 'godown-1',
      );

      final request = AddItemFormMapper.toUpdateRequest(
        form,
        baseUnitShortName: 'PCS',
        openingGodownId: 'fallback-godown',
        godownIdForLocation: 'fallback-godown',
        initialOpeningQty: 5,
      );

      expect(request.openingQuantity, '11');
      expect(request.openingCostPerUnit, '100');
      expect(request.openingGodownId, 'godown-1');
    });

    test('omits opening stock on update when quantity unchanged', () {
      const form = AddItemFormState(
        itemName: 'Hairpin',
        openingQty: 11,
        atPrice: 100,
        godownId: 'godown-1',
      );

      final request = AddItemFormMapper.toUpdateRequest(
        form,
        baseUnitShortName: 'PCS',
        openingGodownId: 'fallback-godown',
        godownIdForLocation: 'fallback-godown',
        initialOpeningQty: 11,
      );

      expect(request.openingQuantity, isNull);
      expect(request.openingCostPerUnit, isNull);
      expect(request.openingGodownId, isNull);
    });
  });

  group('CategoryMapper', () {
    test('uncategorized virtual category uses sentinel id', () {
      final category = CategoryMapper.uncategorized(itemCount: 3);
      expect(category.id, uncategorizedCategoryId);
      expect(category.isUncategorized, isTrue);
      expect(category.itemCount, 3);
    });

    test('toApiCategoryId clears uncategorized sentinel', () {
      expect(CategoryMapper.toApiCategoryId(uncategorizedCategoryId), isNull);
      expect(CategoryMapper.toApiCategoryId('real-id'), 'real-id');
    });

    test('withSyncedItemCounts derives counts from loaded items', () {
      const generalId = 'general-id';
      final synced = CategoryMapper.withSyncedItemCounts(
        categories: const [
          InventoryCategory(id: generalId, name: 'General'),
        ],
        items: const [
          InventoryItem(id: '1', name: 'A', type: ItemType.product, categoryId: generalId),
          InventoryItem(id: '2', name: 'B', type: ItemType.product, categoryId: generalId),
          InventoryItem(id: '3', name: 'C', type: ItemType.product),
        ],
      );

      expect(
        synced.firstWhere((category) => category.id == generalId).itemCount,
        2,
      );
      expect(
        synced.firstWhere((category) => category.isUncategorized).itemCount,
        1,
      );
    });
  });

  group('InventoryErrorMapper', () {
    test('maps known inventory exceptions', () {
      expect(
        InventoryErrorMapper.messageFor(
          const InventoryException(
            'Cannot delete category with existing items.',
          ),
        ),
        'Cannot delete category with existing items.',
      );
      expect(
        InventoryErrorMapper.messageFor(const InventoryOfflineException()),
        contains('Network unavailable'),
      );
    });
  });
}
