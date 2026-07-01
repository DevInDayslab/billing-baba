import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/unit_model.dart';
import 'package:billing_baba/features/inventory/providers/inventory_catalog.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productsProvider = Provider<List<InventoryItem>>((ref) {
  final query = ref.watch(productSearchQueryProvider).toLowerCase();
  return ref.watch(inventoryItemsProvider)
      .where((item) => item.type == ItemType.product)
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final servicesProvider = FutureProvider<List<InventoryItem>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 800));
  final query = ref.watch(serviceSearchQueryProvider).toLowerCase();
  return ref.watch(inventoryItemsProvider)
      .where((item) => item.type == ItemType.service)
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final categoriesProvider = Provider<List<InventoryCategory>>((ref) {
  final query = ref.watch(categorySearchQueryProvider).toLowerCase();
  return InventoryCatalog.categories
      .where(
        (category) =>
            query.isEmpty || category.name.toLowerCase().contains(query),
      )
      .toList();
});

final categoryItemsProvider = Provider.family<List<InventoryItem>, String>((
  ref,
  categoryId,
) {
  final query = ref.watch(categoryItemSearchQueryProvider).toLowerCase();
  return ref.watch(inventoryItemsProvider)
      .where((item) => item.categoryId == categoryId)
      .where((item) => query.isEmpty || item.name.toLowerCase().contains(query))
      .toList();
});

final unitsProvider = Provider<List<InventoryUnit>>((ref) {
  final query = ref.watch(unitSearchQueryProvider).toLowerCase();
  return InventoryCatalog.units
      .where(
        (unit) =>
            query.isEmpty ||
            unit.fullName.toLowerCase().contains(query) ||
            unit.shortName.toLowerCase().contains(query),
      )
      .toList();
});

final selectedProductIdProvider =
    NotifierProvider<SelectedProductId, String?>(SelectedProductId.new);

final selectedServiceIdProvider =
    NotifierProvider<SelectedServiceId, String?>(SelectedServiceId.new);

final selectedCategoryIdProvider =
    NotifierProvider<SelectedCategoryId, String?>(SelectedCategoryId.new);

final selectedUnitIdProvider =
    NotifierProvider<SelectedUnitId, String?>(SelectedUnitId.new);

final productSearchQueryProvider =
    NotifierProvider<ProductSearchQuery, String>(ProductSearchQuery.new);

final serviceSearchQueryProvider =
    NotifierProvider<ServiceSearchQuery, String>(ServiceSearchQuery.new);

final categorySearchQueryProvider =
    NotifierProvider<CategorySearchQuery, String>(CategorySearchQuery.new);

final categoryItemSearchQueryProvider =
    NotifierProvider<CategoryItemSearchQuery, String>(
      CategoryItemSearchQuery.new,
    );

final unitSearchQueryProvider =
    NotifierProvider<UnitSearchQuery, String>(UnitSearchQuery.new);

final unitConversionSearchQueryProvider =
    NotifierProvider<UnitConversionSearchQuery, String>(
      UnitConversionSearchQuery.new,
    );

class SelectedProductId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

class SelectedServiceId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

class SelectedCategoryId extends Notifier<String?> {
  @override
  String? build() => InventoryCatalog.uncategorizedCategoryId;

  void select(String? id) => state = id;
}

class SelectedUnitId extends Notifier<String?> {
  @override
  String? build() => InventoryCatalog.units.first.id;

  void select(String? id) => state = id;
}

class ProductSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class ServiceSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class CategorySearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class CategoryItemSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class UnitSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

class UnitConversionSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}
