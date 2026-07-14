import 'package:billing_baba/features/dashboard/application/global_search_service.dart';
import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:billing_baba/features/inventory/providers/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_search_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_search_provider.g.dart';

@riverpod
class GlobalSearchQuery extends _$GlobalSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

@riverpod
Future<List<GlobalSearchResult>> globalSearchResults(Ref ref) async {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.trim().length < 2) return const [];

  final service = await ref.watch(globalSearchServiceProvider.future);
  final partyResults = await service.searchParties(query);

  final engine = ref.watch(inventorySearchEngineProvider);
  final items = ref.watch(inventoryItemsProvider).value ?? const [];
  final matchedItems = searchInventoryItems(engine, items, query: query).take(8);

  final itemResults = matchedItems
      .map(
        (item) => GlobalSearchResult(
          type: GlobalSearchResultType.item,
          id: item.id,
          title: item.name,
          subtitle: item.baseUnitShortName ?? item.type.name,
        ),
      )
      .toList();

  return [...partyResults, ...itemResults];
}
