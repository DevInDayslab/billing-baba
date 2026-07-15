import 'package:billing_baba/features/dashboard/models/global_search_result.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_search_service.g.dart';

@Riverpod(keepAlive: true)
Future<GlobalSearchService> globalSearchService(Ref ref) async {
  final partyService = await ref.watch(partyServiceProvider.future);
  return GlobalSearchService(partyService: partyService);
}

class GlobalSearchService {
  GlobalSearchService({required this._partyService});

  final PartyService _partyService;

  static const _resultLimit = 8;

  Future<List<GlobalSearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    return searchParties(trimmed);
  }

  Future<List<GlobalSearchResult>> searchParties(String query) async {
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
}
