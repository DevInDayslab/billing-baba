import 'package:billing_baba/features/search/application/fuzzy_search.dart';
import 'package:billing_baba/features/search/application/recent_search_storage.dart';
import 'package:billing_baba/features/search/application/search_registry.dart';
import 'package:billing_baba/features/search/application/search_shortcuts.dart';
import 'package:billing_baba/features/search/domain/search_category.dart';
import 'package:billing_baba/features/search/domain/search_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_repository.g.dart';

/// Resolves grouped search results for the command palette.
@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(ref);
}

class SearchRepository {
  SearchRepository(this._ref);

  final Ref _ref;

  Future<List<SearchResultSection>> sectionsForQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _emptyQuerySections();
    }
    return _filteredSections(trimmed);
  }

  Future<List<SearchResultSection>> _emptyQuerySections() async {
    final recentIds = await _ref
        .read(recentSearchStorageProvider)
        .readRecentPageIds();
    final recentItems = <SearchItem>[];
    for (final id in recentIds) {
      final item = SearchRegistry.byId(id);
      if (item != null && item.isPage) {
        recentItems.add(item);
      }
    }

    final suggestedItems = <SearchItem>[];
    for (final id in SearchShortcuts.suggestedPageIds) {
      final item = SearchRegistry.byId(id);
      if (item != null) suggestedItems.add(item);
    }

    return [
      if (recentItems.isNotEmpty)
        SearchResultSection(
          kind: SearchSectionKind.recentPages,
          items: recentItems,
        ),
      if (suggestedItems.isNotEmpty)
        SearchResultSection(
          kind: SearchSectionKind.suggestedPages,
          items: suggestedItems,
        ),
    ];
  }

  List<SearchResultSection> _filteredSections(String query) {
    final pages = FuzzySearch.filter(
      items: SearchRegistry.pages(),
      query: query,
    );
    final commands = FuzzySearch.filter(
      items: SearchRegistry.commands(),
      query: query,
    );

    return [
      if (pages.isNotEmpty)
        SearchResultSection(kind: SearchSectionKind.pages, items: pages),
      if (commands.isNotEmpty)
        SearchResultSection(kind: SearchSectionKind.commands, items: commands),
    ];
  }

  List<SearchItem> flattenSections(List<SearchResultSection> sections) {
    return sections.expand((section) => section.items).toList(growable: false);
  }
}
