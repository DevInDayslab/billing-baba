/// Filter dimensions for the mobile stock summary screen.
enum StockSummaryFilterSection {
  category('By Item Category'),
  stock('By Stock'),
  status('By Status');

  const StockSummaryFilterSection(this.label);

  final String label;
}

enum StockSummaryStockFilter {
  all('All'),
  inStock('In-Stock Items'),
  lowStock('Low Stock Items');

  const StockSummaryStockFilter(this.label);

  final String label;
}

enum StockSummaryStatusFilter {
  all('All'),
  active('Active'),
  inactive('Inactive');

  const StockSummaryStatusFilter(this.label);

  final String label;
}

/// Mobile stock summary filter state — synced to [reportFiltersProvider] on apply.
class StockSummaryMobileFilters {
  const StockSummaryMobileFilters({
    this.categoryId,
    this.categoryLabel = 'All',
    this.stock = StockSummaryStockFilter.all,
    this.status = StockSummaryStatusFilter.all,
  });

  final String? categoryId;
  final String categoryLabel;
  final StockSummaryStockFilter stock;
  final StockSummaryStatusFilter status;

  bool get hasActiveFilters =>
      categoryId != null ||
      stock != StockSummaryStockFilter.all ||
      status != StockSummaryStatusFilter.all;

  String get categoryChipLabel => 'Item Category - $categoryLabel';

  String get stockChipLabel => 'Stock - ${stock.label}';

  String get statusChipLabel => 'Status - ${status.label}';

  StockSummaryMobileFilters copyWith({
    String? categoryId,
    String? categoryLabel,
    StockSummaryStockFilter? stock,
    StockSummaryStatusFilter? status,
    bool clearCategory = false,
  }) {
    return StockSummaryMobileFilters(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryLabel: clearCategory ? 'All' : (categoryLabel ?? this.categoryLabel),
      stock: stock ?? this.stock,
      status: status ?? this.status,
    );
  }

  static const initial = StockSummaryMobileFilters();

  static StockSummaryStockFilter? stockFilterFromQuery(String? value) {
    return switch (value) {
      'low' => StockSummaryStockFilter.lowStock,
      'in' => StockSummaryStockFilter.inStock,
      _ => null,
    };
  }
}
