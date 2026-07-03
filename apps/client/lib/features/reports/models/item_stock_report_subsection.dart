enum ItemStockReportSubSection {
  stockSummary('Stock Summary'),
  stockDetail('Stock Detail Report'),
  itemWiseProfitLoss('Item Wise Profit/Loss'),
  lowStockDetails('Low Stock Details'),
  itemReportByParty('Item Report By Party');

  const ItemStockReportSubSection(this.label);

  final String label;
}
