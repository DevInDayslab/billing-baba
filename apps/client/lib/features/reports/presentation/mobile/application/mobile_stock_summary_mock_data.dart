import 'package:billing_baba/features/reports/presentation/mobile/models/stock_summary_display_row.dart';

/// Demo stock summary rows for mobile UI previews when the report API is empty.
abstract final class MobileStockSummaryMockData {
  static const rows = <StockSummaryDisplayRow>[
    StockSummaryDisplayRow(
      itemName: 'Bosch All-in-One Metal Hand Tool Kit',
      stockValue: 2535,
      stockQty: 1,
      salePrice: 2535,
      purchasePrice: 2100,
    ),
    StockSummaryDisplayRow(
      itemName: 'caty',
      categoryId: 'glasses',
      categoryName: 'GLASSES',
      stockValue: 775,
      stockQty: 28,
      reservedQty: 1,
      availableQty: 27,
      salePrice: 28,
      purchasePrice: 22,
    ),
    StockSummaryDisplayRow(
      itemName: 'COKE',
      categoryId: 'solvents',
      categoryName: 'SOLVENTS',
      stockValue: 297.54,
      stockQty: 93,
      salePrice: 3.2,
      purchasePrice: 2.8,
    ),
    StockSummaryDisplayRow(
      itemName: 'creme',
      stockValue: 171,
      stockQty: 19,
      salePrice: 9,
      purchasePrice: 7,
    ),
    StockSummaryDisplayRow(
      itemName: 'dsfgdfg',
      stockValue: 0,
      stockQty: 1,
      salePrice: 0,
      purchasePrice: 0,
    ),
    StockSummaryDisplayRow(
      itemName: 'Hi',
      stockValue: 0,
      stockQty: 0,
      salePrice: 0,
      purchasePrice: 0,
      isInactive: true,
    ),
    StockSummaryDisplayRow(
      itemName: 'Classic Reading Glasses',
      categoryId: 'glasses',
      categoryName: 'GLASSES',
      stockValue: 2800,
      stockQty: 28,
      reservedQty: 1,
      availableQty: 27,
      salePrice: 100,
      purchasePrice: 29,
    ),
    StockSummaryDisplayRow(
      itemName: 'Amul Taaza Milk 1L',
      categoryId: 'dairy',
      categoryName: 'DAIRY',
      stockValue: 1392,
      stockQty: 24,
      salePrice: 65,
      purchasePrice: 58,
    ),
    StockSummaryDisplayRow(
      itemName: 'Fortune Sunflower Oil 1L',
      categoryId: 'grocery',
      categoryName: 'GROCERY',
      stockValue: 0,
      stockQty: 0,
      salePrice: 145,
      purchasePrice: 130,
    ),
    StockSummaryDisplayRow(
      itemName: 'Maggi 2-Min Noodles',
      categoryId: 'snacks',
      categoryName: 'SNACKS',
      stockValue: 440,
      stockQty: 3,
      salePrice: 14,
      purchasePrice: 11,
    ),
  ];

  static const totalStockValue = 63100000.0;
  static const itemCount = 24;
  static const lowStockCount = 8;
}
