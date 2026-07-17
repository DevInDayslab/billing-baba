import 'package:billing_baba/features/search/domain/search_item.dart';

/// Lightweight fuzzy matcher for page/command search.
abstract final class FuzzySearch {
  static String normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  /// Returns matching items sorted by relevance (highest first).
  static List<SearchItem> filter({
    required Iterable<SearchItem> items,
    required String query,
  }) {
    final normalizedQuery = normalize(query.trim());
    if (normalizedQuery.isEmpty) return [];

    final scored = <({SearchItem item, int score})>[];
    for (final item in items) {
      final score = _scoreItem(item, normalizedQuery);
      if (score > 0) {
        scored.add((item: item, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((entry) => entry.item).toList(growable: false);
  }

  static int _scoreItem(SearchItem item, String query) {
    var best = 0;
    best = _maxScore(
      best,
      _scoreText(normalize(item.title), query, title: true),
    );

    for (final keyword in item.keywords) {
      best = _maxScore(
        best,
        _scoreText(normalize(keyword), query, title: false),
      );
    }

    if (item.subtitle != null) {
      best = _maxScore(
        best,
        _scoreText(normalize(item.subtitle!), query, title: false),
      );
    }

    return best;
  }

  static int _scoreText(String text, String query, {required bool title}) {
    if (text.isEmpty || query.isEmpty) return 0;

    if (text.startsWith(query)) {
      return title ? 100 : 80;
    }
    if (text.contains(query)) {
      return title ? 60 : 40;
    }
    return 0;
  }

  static int _maxScore(int current, int candidate) =>
      candidate > current ? candidate : current;
}
