enum ItemStockReportSubSection {
  stockSummary('Stock Summary'),
  itemReportByParty('Item Report By Party'),
  itemWiseProfitLoss('Item Wise Profit And Loss'),
  lowStockSummary('Low Stock Summary'),
  stockDetail('Stock Detail Report'),
  itemDetail('Item Detail'),
  salePurchaseReportByItemCategory('Sale/Purchase Report By Item Category'),
  stockSummaryReportByItemCategory('Stock Summary Report By Item Category'),
  itemCategoryWiseProfitLoss('Item Category Wise Profit And Loss'),
  itemWiseDiscount('Item Wise Discount'),
  manufacturingReport('Manufacturing Report'),
  consumptionReport('Consumption Report'),
  stockTransferReport('Stock Transfer Report');

  const ItemStockReportSubSection(this.label);

  final String label;
}
