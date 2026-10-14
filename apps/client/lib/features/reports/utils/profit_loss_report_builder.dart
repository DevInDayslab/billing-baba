import 'dart:math' as math;

import 'package:billing_baba/features/reports/models/report_models.dart';

class ProfitLossBuiltReport {
  const ProfitLossBuiltReport({
    required this.items,
    required this.netProfit,
  });

  final List<ReportProfitLossItem> items;
  final double netProfit;
}

/// Builds P&amp;L line items using the same structure as the API accounting report.
class ProfitLossReportBuilder {
  const ProfitLossReportBuilder._();

  static ProfitLossBuiltReport build({
    required double netSales,
    required double netPurchases,
    required double expenseTotal,
    double stockValue = 0,
  }) {
    final saleAccountsTotal = netSales;
    const otherDirectTotal = 0.0;
    const otherIndirectTotal = 0.0;
    final totalIncomes =
        saleAccountsTotal + otherDirectTotal + otherIndirectTotal;

    final openingStock = math.max(0.0, stockValue - netPurchases);
    final closingStock = stockValue;
    final costOfGoodsSold = openingStock + netPurchases - closingStock;
    const directExpenses = 0.0;
    final indirectExpenses = expenseTotal;
    final totalExpenses = costOfGoodsSold + directExpenses + indirectExpenses;

    final netProfit = netSales - netPurchases - expenseTotal;

    ReportProfitLossItem row(
      String particular,
      double amount, {
      bool isHeader = false,
      int indent = 0,
    }) {
      return ReportProfitLossItem(
        particular: particular,
        amount: amount,
        isHeader: isHeader,
        indent: indent,
      );
    }

    final items = <ReportProfitLossItem>[
      row('Incomes', totalIncomes, isHeader: true),
      row('Sale Accounts', saleAccountsTotal, isHeader: true, indent: 1),
      row('Sale (Revenue) Account', netSales, indent: 2),
      row('Additional Charges on Sale', 0, indent: 2),
      row('Other Incomes (Direct)', otherDirectTotal, isHeader: true, indent: 1),
      row('Payment-out Discount', 0, indent: 2),
      row('Other Direct Incomes', 0, indent: 2),
      row(
        'Other Incomes (Indirect)',
        otherIndirectTotal,
        isHeader: true,
        indent: 1,
      ),
      row('Interest Received', 0, indent: 2),
      row('Other Indirect Incomes', 0, indent: 2),
      row('Expenses', totalExpenses, isHeader: true),
      row('Cost of Goods Sold', costOfGoodsSold, isHeader: true, indent: 1),
      row('Purchase Accounts', netPurchases, indent: 2),
      row('Opening Stock', openingStock, indent: 2),
      row('Closing Stock', closingStock, indent: 2),
      row('Direct Expenses', directExpenses, isHeader: true, indent: 1),
      row('Indirect Expenses', indirectExpenses, isHeader: true, indent: 1),
      row('Cost of Financing', 0, indent: 2),
      row('Other Expenses', expenseTotal, indent: 2),
      row('Net Profit (Incomes - Expenses)', netProfit, isHeader: true),
    ];

    return ProfitLossBuiltReport(items: items, netProfit: netProfit);
  }

  static bool hasMeaningfulActivity({
    required List<ReportProfitLossItem> items,
    required double netProfit,
  }) {
    for (final item in items) {
      if (item.isHeader) continue;
      if (item.particular == 'Additional Charges on Sale') continue;
      if (item.particular == 'Payment-out Discount') continue;
      if (item.particular == 'Other Direct Incomes') continue;
      if (item.particular == 'Interest Received') continue;
      if (item.particular == 'Other Indirect Incomes') continue;
      if (item.particular == 'Cost of Financing') continue;
      if (item.amount.abs() > 0.001) return true;
    }
    return netProfit.abs() > 0.001;
  }
}
