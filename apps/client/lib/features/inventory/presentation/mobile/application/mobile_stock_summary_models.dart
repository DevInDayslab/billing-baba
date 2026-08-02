import 'package:billing_baba/features/inventory/models/item_model.dart';

enum MobileStockSummaryStockFilter {
  all('All'),
  inStock('In Stock'),
  outOfStock('Out of Stock');

  const MobileStockSummaryStockFilter(this.label);

  final String label;
}

enum MobileStockSummaryStatusFilter {
  all('All'),
  lowStock('Low Stock'),
  inStock('In Stock'),
  outOfStock('Out of Stock');

  const MobileStockSummaryStatusFilter(this.label);

  final String label;
}

class MobileStockSummaryFilters {
  MobileStockSummaryFilters({
    this.useAsOnDate = false,
    DateTime? asOnDate,
    this.categoryId,
    this.stockFilter = MobileStockSummaryStockFilter.all,
    this.statusFilter = MobileStockSummaryStatusFilter.all,
    this.searchQuery = '',
    this.searchVisible = false,
  }) : asOnDate = asOnDate ?? _defaultAsOnDate();

  static DateTime _defaultAsOnDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  final bool useAsOnDate;
  final DateTime asOnDate;
  final String? categoryId;
  final MobileStockSummaryStockFilter stockFilter;
  final MobileStockSummaryStatusFilter statusFilter;
  final String searchQuery;
  final bool searchVisible;

  MobileStockSummaryFilters copyWith({
    bool? useAsOnDate,
    DateTime? asOnDate,
    String? categoryId,
    bool clearCategoryId = false,
    MobileStockSummaryStockFilter? stockFilter,
    MobileStockSummaryStatusFilter? statusFilter,
    String? searchQuery,
    bool? searchVisible,
  }) {
    return MobileStockSummaryFilters(
      useAsOnDate: useAsOnDate ?? this.useAsOnDate,
      asOnDate: asOnDate ?? this.asOnDate,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      stockFilter: stockFilter ?? this.stockFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      searchVisible: searchVisible ?? this.searchVisible,
    );
  }
}

class MobileStockSummaryMetrics {
  const MobileStockSummaryMetrics({
    required this.itemCount,
    required this.lowStockCount,
    required this.totalStockValue,
  });

  final int itemCount;
  final int lowStockCount;
  final double totalStockValue;
}

class MobileStockSummaryRow {
  const MobileStockSummaryRow({
    required this.item,
    required this.stockQty,
    required this.stockValue,
    required this.isLowStock,
  });

  final InventoryItem item;
  final double stockQty;
  final double stockValue;
  final bool isLowStock;
}

bool isMobileStockSummaryLowStock(InventoryItem item) {
  final quantity = item.quantity;
  if (quantity == null || quantity <= 0) return false;

  final reorder = item.reorderLevel;
  if (reorder != null) return quantity <= reorder;

  return quantity <= 14;
}

double resolveMobileStockSummaryValue(InventoryItem item) {
  final stockValue = item.stockValue;
  if (stockValue != null && stockValue > 0) return stockValue;

  final qty = item.quantity ?? 0;
  final unitCost = item.purchasePrice ?? item.salePrice ?? 0;
  return qty * unitCost;
}
