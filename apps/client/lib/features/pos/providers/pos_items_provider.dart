import 'package:billing_baba/features/inventory/providers/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/providers/pos_repository_provider.dart';
import 'package:billing_baba/features/pos/repositories/pos_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_items_provider.g.dart';

@riverpod
class PosItemSearchQuery extends _$PosItemSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

@riverpod
Future<List<PosItem>> posItems(Ref ref) async {
  ref.watch(inventoryItemsProvider);
  ref.watch(inventoryCategoriesProvider);
  final repository = await ref.watch(posRepositoryProvider.future);
  return repository.getItems();
}

@riverpod
Future<List<PosItem>> posItemSearch(Ref ref, String query) async {
  ref.watch(inventoryItemsProvider);
  ref.watch(inventoryCategoriesProvider);
  final repository = await ref.watch(posRepositoryProvider.future);
  if (query.isEmpty) return repository.getItems();
  return repository.searchItems(query);
}

@riverpod
Future<List<PosCustomer>> posCustomerSearch(Ref ref, String query) async {
  final repository = await ref.watch(posRepositoryProvider.future);
  if (query.isEmpty) return [];
  return repository.searchCustomers(query);
}
