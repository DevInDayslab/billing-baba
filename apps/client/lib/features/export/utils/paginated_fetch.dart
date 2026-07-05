/// Fetches all pages from a paginated API using an existing fetch function.
abstract final class PaginatedFetch {
  static const defaultPageSize = 100;
  static const maxPages = 200;

  /// Loop [fetchPage] until all items are collected or [maxPages] is reached.
  static Future<List<T>> fetchAll<T>({
    required Future<({List<T> items, int totalPages})> Function(int page)
    fetchPage,
    int startPage = 1,
  }) async {
    final allItems = <T>[];
    var page = startPage;
    var totalPages = 1;

    while (page <= totalPages && page <= maxPages) {
      final result = await fetchPage(page);
      allItems.addAll(result.items);
      totalPages = result.totalPages;
      if (result.items.isEmpty) break;
      page++;
    }

    return allItems;
  }
}
