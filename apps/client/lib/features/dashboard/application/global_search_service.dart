import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_search_service.g.dart';

@Riverpod(keepAlive: true)
Future<GlobalSearchService> globalSearchService(Ref ref) async {
  final partyService = await ref.watch(partyServiceProvider.future);
  final inventoryService = await ref.watch(inventoryServiceProvider.future);
  return GlobalSearchService(
    partyService: partyService,
    inventoryService: inventoryService,
  );
}

class GlobalSearchService {
  GlobalSearchService({
    required this._partyService,
    required this._inventoryService,
  });

  final PartyService _partyService;
  final InventoryService _inventoryService;

  static const _resultLimit = 8;

  Future<List<GlobalSearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final results = await Future.wait([
      _searchParties(trimmed),
      _searchItems(trimmed),
    ]);

    return [...results[0], ...results[1]];
  }

  Future<List<GlobalSearchResult>> _searchParties(String query) async {
    final parties = await _partyService.fetchParties(searchQuery: query);
    return parties.take(_resultLimit).map((party) {
      return GlobalSearchResult(
        type: GlobalSearchResultType.party,
        id: party.id,
        title: party.name,
        subtitle: party.phone,
      );
    }).toList();
  }

  Future<List<GlobalSearchResult>> _searchItems(String query) async {
    final items = await _inventoryService.fetchItems(searchQuery: query);
    return items.take(_resultLimit).map((item) {
      return GlobalSearchResult(
        type: GlobalSearchResultType.item,
        id: item.id,
        title: item.name,
        subtitle: item.baseUnitShortName ?? item.type.name,
      );
    }).toList();
  }
}
