import 'package:billing_baba/features/reports/models/report_models.dart';

/// View model for a stock summary list row on mobile.
class StockSummaryDisplayRow {
  const StockSummaryDisplayRow({
    required this.itemName,
    required this.stockValue,
    required this.stockQty,
    this.categoryId,
    this.categoryName,
    this.reservedQty,
    this.availableQty,
    this.salePrice = 0,
    this.purchasePrice = 0,
    this.isInactive = false,
  });

  factory StockSummaryDisplayRow.fromReportRow(ReportStockSummaryRow row) {
    return StockSummaryDisplayRow(
      itemName: row.itemName,
      stockValue: row.stockValue,
      stockQty: row.stockQty,
      categoryId: row.categoryId.isEmpty ? null : row.categoryId,
      salePrice: row.salePrice,
      purchasePrice: row.purchasePrice,
    );
  }

  final String itemName;
  final double stockValue;
  final double stockQty;
  final String? categoryId;
  final String? categoryName;
  final double? reservedQty;
  final double? availableQty;
  final double salePrice;
  final double purchasePrice;
  final bool isInactive;

  bool get hasCategory => categoryName != null && categoryName!.isNotEmpty;

  bool get hasQuantityBreakdown =>
      (reservedQty != null && reservedQty! > 0) ||
      (availableQty != null && availableQty != stockQty);

  bool get isLowStock => stockQty > 0 && stockQty <= 10;

  bool get isInStock => stockQty > 0;

  StockSummaryDisplayRow withCategoryName(String? name) {
    if (name == null || name.isEmpty) return this;
    return StockSummaryDisplayRow(
      itemName: itemName,
      stockValue: stockValue,
      stockQty: stockQty,
      categoryId: categoryId,
      categoryName: name.toUpperCase(),
      reservedQty: reservedQty,
      availableQty: availableQty,
      salePrice: salePrice,
      purchasePrice: purchasePrice,
      isInactive: isInactive,
    );
  }
}
