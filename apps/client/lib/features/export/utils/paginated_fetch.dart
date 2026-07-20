/// Fetches all pages from a paginated API using an existing fetch function.
abstract final class PaginatedFetch {
  static const defaultPageSize = 100;
  static const maxPages = 200;

  /// Fetches page 1 first, then loads remaining pages in parallel.
  static Future<List<T>> fetchAll<T>({
    required Future<({List<T> items, int totalPages})> Function(int page)
    fetchPage,
    int startPage = 1,
  }) async {
    final firstResult = await fetchPage(startPage);
    final allItems = <T>[...firstResult.items];
    if (firstResult.items.isEmpty) return allItems;

    final totalPages = firstResult.totalPages.clamp(1, maxPages);
    if (totalPages <= startPage) return allItems;

    final remainingPages = [
      for (var page = startPage + 1; page <= totalPages; page++) page,
    ];
    final pageResults = await Future.wait(
      remainingPages.map(fetchPage),
    );

    for (final result in pageResults) {
      allItems.addAll(result.items);
      if (result.items.isEmpty) break;
    }

    return allItems;
  }
}
