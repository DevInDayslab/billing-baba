import 'package:billing_baba/features/collaboration/application/navigation_permission_registry.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/settings/application/general_settings_provider.dart';
import 'package:billing_baba/features/settings/models/general_settings.dart';
import 'package:billing_baba/features/search/application/recent_search_storage.dart';
import 'package:billing_baba/features/search/application/search_matcher.dart';
import 'package:billing_baba/features/search/application/search_registry.dart';
import 'package:billing_baba/features/search/application/search_shortcuts.dart';
import 'package:billing_baba/features/search/domain/search_category.dart';
import 'package:billing_baba/features/search/domain/search_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_repository.g.dart';

/// Resolves grouped search results for the navigation palette.
@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(ref);
}

class SearchRepository {
  SearchRepository(this._ref);

  final Ref _ref;

  /// Sync filter against the static registry — no I/O.
  List<SearchResultSection> filteredSections(String query) {
    final permissions = _ref.read(permissionServiceProvider);
    final general =
        _ref.read(generalSettingsProvider).value ?? GeneralSettings.defaults();
    final pages = SearchMatcher.filter(
      items: SearchRegistry.visiblePages(
        permissions,
        generalSettings: general,
      ),
      query: query,
    );
    final commands = SearchMatcher.filter(
      items: SearchRegistry.commands,
      query: query,
    );

    return [
      if (pages.isNotEmpty)
        SearchResultSection(kind: SearchSectionKind.pages, items: pages),
      if (commands.isNotEmpty)
        SearchResultSection(kind: SearchSectionKind.commands, items: commands),
    ];
  }

  /// Suggested pages only — sync, no I/O.
  List<SearchResultSection> suggestedSections() {
    final permissions = _ref.read(permissionServiceProvider);
    final suggestedItems = <SearchItem>[];
    for (final id in SearchShortcuts.suggestedPageIds) {
      final item = SearchRegistry.byId(id);
      if (item == null || item.route == null) continue;
      if (!NavigationPermissionRegistry.isVisible(item.route!, permissions)) {
        continue;
      }
      suggestedItems.add(item);
    }

    if (suggestedItems.isEmpty) return const [];

    return [
      SearchResultSection(
        kind: SearchSectionKind.suggestedPages,
        items: suggestedItems,
      ),
    ];
  }

  /// Recent + suggested sections for an empty query.
  Future<List<SearchResultSection>> emptyQuerySections() async {
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

  List<SearchItem> flattenSections(List<SearchResultSection> sections) {
    return sections.expand((section) => section.items).toList(growable: false);
  }
}
