from pathlib import Path

path = Path("lib/features/sales/providers/sale_invoices_provider.dart")
text = path.read_text(encoding="utf-8")
start = text.find("class SaleInvoices extends")
end = text.find("Future<String?> deleteDraft", start)
if start == -1 or end == -1:
    raise SystemExit("markers not found")

new_block = """class SaleInvoices extends _$SaleInvoices {
  List<SaleInvoiceModel>? _cachedFullList;
  Object? _cachedServerQueryKey;

  @override
  Future<PaginatedSaleInvoices> build() async {
    ref.watch(saleInvoiceFiltersProvider);
    ref.watch(saleInvoiceSearchQueryProvider);
    return _fetchPage();
  }

  Object _serverQueryKey(SaleInvoiceFiltersState filters, String search) => (
    filters.timeRangeOption,
    filters.customDateRange?.start.millisecondsSinceEpoch,
    filters.customDateRange?.end.millisecondsSinceEpoch,
    search.trim(),
  );

  Future<PaginatedSaleInvoices> _fetchPage() async {
    final filters = ref.read(saleInvoiceFiltersProvider);
    final search = ref.read(saleInvoiceSearchQueryProvider);
    final service = await ref.read(salesServiceProvider.future);
    final queryKey = _serverQueryKey(filters, search);

    if (needsSaleInvoiceClientSideFiltering(filters)) {
      if (_cachedFullList == null || _cachedServerQueryKey != queryKey) {
        _cachedServerQueryKey = queryKey;
        _cachedFullList = await PaginatedFetch.fetchAll<SaleInvoiceModel>(
          fetchPage: (page) async {
            final result = await service.fetchInvoicesPage(
              _buildListQuery(
                filters,
                search,
                page: page,
                limit: PaginatedFetch.defaultPageSize,
              ),
            );
            return (items: result.items, totalPages: result.totalPages);
          },
        );
      }

      final filteredItems = applySaleInvoiceClientFilters(
        _cachedFullList!,
        filters,
      );
      return paginateSaleInvoiceItems(filteredItems, filters);
    }

    _cachedFullList = null;
    _cachedServerQueryKey = null;

    final page = await service.fetchInvoicesPage(
      _buildListQuery(filters, search),
    );

    return PaginatedSaleInvoices(
      items: page.items,
      currentPage: page.currentPage,
      totalPages: page.totalPages,
      totalItems: page.totalItems,
      summary: page.summary,
    );
  }

  Future<void> refresh() async {
    _cachedFullList = null;
    _cachedServerQueryKey = null;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchPage);
  }

  """

path.write_text(text[:start] + new_block + text[end:], encoding="utf-8", newline="\n")
print("patched")
