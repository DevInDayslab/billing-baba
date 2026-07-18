import 'package:billing_baba/features/search/domain/search_item.dart';

/// Deterministic text normalization for navigation search.
abstract final class SearchTextNormalizer {
  static String normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[/\-_&]+'), ' ')
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String compact(String value) => normalize(value).replaceAll(' ', '');

  static List<String> words(String normalized) {
    if (normalized.isEmpty) return const [];
    return normalized.split(' ').where((word) => word.isNotEmpty).toList();
  }
}

enum _MatchTier {
  exactTitle(1),
  titleStartsWith(2),
  wordStartsWith(3),
  titleContains(4),
  keywordContains(5);

  const _MatchTier(this.priority);

  final int priority;
}

/// Deterministic navigation search — no fuzzy or similarity matching.
abstract final class SearchMatcher {
  static List<SearchItem> filter({
    required Iterable<SearchItem> items,
    required String query,
  }) {
    final normalizedQuery = SearchTextNormalizer.normalize(query);
    if (normalizedQuery.isEmpty) return const [];

    final ranked = <({SearchItem item, int tier, String title})>[];
    for (final item in items) {
      final tier = _matchTier(item, normalizedQuery);
      if (tier == null) continue;
      ranked.add((item: item, tier: tier.priority, title: item.title));
    }

    ranked.sort((a, b) {
      final tierCompare = a.tier.compareTo(b.tier);
      if (tierCompare != 0) return tierCompare;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return ranked.map((entry) => entry.item).toList(growable: false);
  }

  static _MatchTier? _matchTier(SearchItem item, String normalizedQuery) {
    final compactQuery = SearchTextNormalizer.compact(normalizedQuery);
    final normalizedTitle = SearchTextNormalizer.normalize(item.title);
    final compactTitle = SearchTextNormalizer.compact(item.title);

    if (normalizedTitle == normalizedQuery || compactTitle == compactQuery) {
      return _MatchTier.exactTitle;
    }

    if (normalizedTitle.startsWith(normalizedQuery) ||
        compactTitle.startsWith(compactQuery)) {
      return _MatchTier.titleStartsWith;
    }

    final titleWords = SearchTextNormalizer.words(normalizedTitle);
    final queryWords = SearchTextNormalizer.words(normalizedQuery);
    if (queryWords.isNotEmpty &&
        queryWords.every(
          (queryWord) => titleWords.any((titleWord) {
            return titleWord.startsWith(queryWord);
          }),
        )) {
      return _MatchTier.wordStartsWith;
    }

    if (normalizedTitle.contains(normalizedQuery) ||
        compactTitle.contains(compactQuery)) {
      return _MatchTier.titleContains;
    }

    for (final keyword in item.keywords) {
      final normalizedKeyword = SearchTextNormalizer.normalize(keyword);
      final compactKeyword = SearchTextNormalizer.compact(keyword);
      if (normalizedKeyword.contains(normalizedQuery) ||
          compactKeyword.contains(compactQuery)) {
        return _MatchTier.keywordContains;
      }
    }

    final subtitle = item.subtitle;
    if (subtitle != null) {
      final normalizedSubtitle = SearchTextNormalizer.normalize(subtitle);
      final compactSubtitle = SearchTextNormalizer.compact(subtitle);
      if (normalizedSubtitle.contains(normalizedQuery) ||
          compactSubtitle.contains(compactQuery)) {
        return _MatchTier.keywordContains;
      }
    }

    return null;
  }
}
