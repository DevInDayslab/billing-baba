enum TransactionReportSubSection {
  sale('Sale'),
  purchase('Purchase'),
  dayBook('Day book'),
  allTransaction('All Transactions'),
  profitLoss('Profit And Loss'),
  billWiseProfit('Bill Wise Profit'),
  cashFlow('Cash flow'),
  trialBalance('Trial Balance Report', showNotificationDot: true),
  balanceSheet('Balance Sheet');

  const TransactionReportSubSection(
    this.label, {
    this.showNotificationDot = false,
  });

  final String label;
  final bool showNotificationDot;
}
