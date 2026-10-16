import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/pos/application/pos_catalog.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

PosItem posItemFromAlternative(
  WidgetRef ref,
  AlternativeItemDto alternative,
  CartItem originalLine,
) {
  final inventoryItems = ref.read(inventoryItemListProvider);
  final categories = ref.read(inventoryCategoriesProvider).value ?? const [];
  final categoryNames = categoryNamesById(categories);
  final live = findLivePosItem(
    itemId: alternative.id,
    inventoryItems: inventoryItems,
    categoryNamesById: categoryNames,
  );
  if (live != null) return live;

  return PosItem(
    id: alternative.id,
    name: alternative.name,
    sku: alternative.barcode ?? alternative.id,
    categoryName: alternative.categoryName ?? originalLine.item.categoryName,
    price: alternative.salePrice,
    stock: alternative.stockQuantity.round(),
    brandName: alternative.brandName,
  );
}
