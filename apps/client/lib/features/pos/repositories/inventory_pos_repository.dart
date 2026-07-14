import 'package:billing_baba/features/inventory/application/inventory_stock_calculator.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_search_provider.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_state.dart';
import 'package:billing_baba/features/pos/repositories/mock_pos_repository.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// POS catalog backed by live inventory data; customers remain mock until wired.
class InventoryPosRepository implements PosRepository {
  InventoryPosRepository(this._ref);

  final Ref _ref;
  final _customers = MockPosRepository();

  Future<List<InventoryItem>> _loadItems() async {
    final cached = _ref.read(inventoryItemsProvider).value;
    if (cached != null) return cached;
    return _ref.read(inventoryItemsProvider.future);
  }

  Future<List<InventoryCategory>> _loadCategories() async {
    final cached = _ref.read(inventoryCategoriesProvider).value;
    if (cached != null) return cached;
    return _ref.read(inventoryCategoriesProvider.future);
  }

  List<PosItem> _mapToPosItems(
    List<InventoryItem> items,
    List<InventoryCategory> categories,
  ) {
    final categoryById = {for (final category in categories) category.id: category.name};

    return items
        .where((item) => item.type == ItemType.product)
        .map((item) {
          final stock =
              InventoryStockCalculator.metricsFromItem(item).availableForSale;
          return PosItem(
            id: item.id,
            name: item.name,
            sku: item.barcode ?? item.id,
            category: categoryById[item.categoryId] ?? 'Uncategorized',
            price: item.salePrice ?? 0,
            stock: stock.round(),
          );
        })
        .toList();
  }

  @override
  Future<List<PosItem>> getItems() async {
    final items = await _loadItems();
    final categories = await _loadCategories();
    return _mapToPosItems(items, categories);
  }

  @override
  Future<List<PosItem>> searchItems(String query) async {
    final inventoryItems = await _loadItems();
    final categories = await _loadCategories();
    final categoryById = {
      for (final category in categories) category.id: category.name,
    };

    final engine = _ref.read(inventorySearchEngineProvider);
    final matchedItems = engine.searchItems(
      inventoryItems.where((item) => item.type == ItemType.product),
      query: query,
    );

    return matchedItems
        .map(
          (item) => PosItem(
            id: item.id,
            name: item.name,
            sku: item.barcode ?? item.id,
            category: categoryById[item.categoryId] ?? 'Uncategorized',
            price: item.salePrice ?? 0,
            stock: InventoryStockCalculator.metricsFromItem(item)
                .availableForSale
                .round(),
          ),
        )
        .toList();
  }

  @override
  Future<String> submitSale({
    required PosCartState cart,
    required String businessId,
  }) {
    return _customers.submitSale(cart: cart, businessId: businessId);
  }

  @override
  Future<List<PosCustomer>> searchCustomers(String query) {
    return _customers.searchCustomers(query);
  }

  @override
  Future<PosCustomer?> getCustomer(String customerId) {
    return _customers.getCustomer(customerId);
  }
}
