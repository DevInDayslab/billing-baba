/// Shared keyword matching for party search (order-independent words).
abstract final class PartySearchMatch {
  static List<String> queryWords(String? query) {
    final normalized = query?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) return const [];
    return normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  static bool matchesFields({
    required List<String> queryWords,
    required Iterable<String?> fields,
  }) {
    if (queryWords.isEmpty) return true;

    final searchableText = fields
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(' ')
        .toLowerCase();

    return queryWords.every(searchableText.contains);
  }
}
