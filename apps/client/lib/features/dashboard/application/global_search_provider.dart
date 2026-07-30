import 'package:billing_baba/features/dashboard/application/global_search_service.dart';
import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_search_provider.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_search_provider.g.dart';

@riverpod
class GlobalSearchQuery extends _$GlobalSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value.trim();

  void clear() => state = '';
}

/// Instant, local item matches (no network).
final globalSearchItemResultsProvider = Provider<List<GlobalSearchResult>>((ref) {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.isEmpty) return const [];

  final engine = ref.watch(inventorySearchEngineProvider);
  final items = ref.watch(inventoryItemsProvider).value ?? const [];

  return searchInventoryItems(engine, items, query: query)
      .take(8)
      .map(
        (item) => GlobalSearchResult(
          type: GlobalSearchResultType.item,
          id: item.id,
          title: item.name,
          subtitle: _itemSearchSubtitle(item),
        ),
      )
      .toList();
});

String _itemSearchSubtitle(InventoryItem item) {
  final barcode = item.barcode?.trim();
  if (barcode != null && barcode.isNotEmpty) return barcode;

  final hsn = item.hsnCode?.trim();
  if (hsn != null && hsn.isNotEmpty) return 'HSN $hsn';

  final unit = item.baseUnitShortName?.trim();
  if (unit != null && unit.isNotEmpty) return unit;

  return item.type.name;
}

/// Parties, invoices, bills, and other remote matches.
// ignore: specify_nonobvious_property_types
final globalSearchAsyncResultsProvider =
    FutureProvider.autoDispose<List<GlobalSearchResult>>((ref) async {
      final query = ref.watch(globalSearchQueryProvider);
      if (query.isEmpty) return const [];

      final service = await ref.watch(globalSearchServiceProvider.future);
      return service.searchAll(query);
    });
