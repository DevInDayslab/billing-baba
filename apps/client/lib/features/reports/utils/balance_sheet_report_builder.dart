import 'dart:math' as math;

import 'package:billing_baba/features/reports/models/report_models.dart';

class BalanceSheetBuiltReport {
  const BalanceSheetBuiltReport({
    required this.assets,
    required this.liabilities,
    required this.assetsTotal,
    required this.liabilitiesTotal,
    required this.netProfit,
    required this.openingAssets,
    required this.closingAssets,
    required this.openingLiabilities,
    required this.closingLiabilities,
    required this.openingEquity,
    required this.closingEquity,
    required this.isBalanced,
    required this.asOn,
  });

  final List<ReportBalanceSheetItem> assets;
  final List<ReportBalanceSheetItem> liabilities;
  final double assetsTotal;
  final double liabilitiesTotal;
  final double netProfit;
  final double openingAssets;
  final double closingAssets;
  final double openingLiabilities;
  final double closingLiabilities;
  final double openingEquity;
  final double closingEquity;
  final bool isBalanced;
  final DateTime asOn;
}

/// Builds balance sheet line items using the same structure as the API accounting report.
class BalanceSheetReportBuilder {
  const BalanceSheetReportBuilder._();

  static BalanceSheetBuiltReport build({
    required double cash,
    required double receivable,
    required double payable,
    required double stockValue,
    required double netProfit,
    required double partyOpening,
    required double openingCash,
    required double openingReceivable,
    required double openingPayable,
    required double openingStock,
    required DateTime asOn,
  }) {
    final assetsTotal = cash + receivable + stockValue;
    final liabilitiesTotal = payable;
    final equityBeforePlug = assetsTotal - liabilitiesTotal;
    final retainedEarnings = equityBeforePlug - partyOpening - netProfit;

    ReportBalanceSheetItem row(
      String name,
      double amount, {
      int indent = 0,
      bool isHeader = false,
    }) {
      return ReportBalanceSheetItem(
        name: name,
        amount: amount,
        indent: indent,
        isHeader: isHeader,
      );
    }

    final assets = <ReportBalanceSheetItem>[
      row('Current Assets', 0, isHeader: true),
      row('Cash & Bank', cash, indent: 1),
      row('Sundry Debtors', receivable, indent: 1),
      row('Stock in Hand', stockValue, indent: 1),
    ];

    final liabilities = <ReportBalanceSheetItem>[
      row('Current Liabilities', 0, isHeader: true),
      row('Sundry Creditors', payable, indent: 1),
      row('Capital & Reserves', 0, isHeader: true),
      row('Capital Account', math.max(0, partyOpening).toDouble(), indent: 1),
      row('Retained Earnings', retainedEarnings, indent: 1),
      row('Net Profit (Period)', netProfit, indent: 1),
    ];

    final liabilitiesAndEquityTotal = liabilitiesTotal + equityBeforePlug;
    final openingAssets = openingCash + openingReceivable + openingStock;
    final openingLiabilities = openingPayable;
    final openingEquity = openingAssets - openingLiabilities;
    final closingEquity = equityBeforePlug;

    return BalanceSheetBuiltReport(
      assets: assets,
      liabilities: liabilities,
      assetsTotal: assetsTotal,
      liabilitiesTotal: liabilitiesAndEquityTotal,
      netProfit: netProfit,
      openingAssets: openingAssets,
      closingAssets: assetsTotal,
      openingLiabilities: openingLiabilities,
      closingLiabilities: liabilitiesAndEquityTotal,
      openingEquity: openingEquity,
      closingEquity: closingEquity,
      isBalanced: (assetsTotal - liabilitiesAndEquityTotal).abs() < 0.02,
      asOn: asOn,
    );
  }

  static bool hasMeaningfulActivity({
    required List<ReportBalanceSheetItem> assets,
    required List<ReportBalanceSheetItem> liabilities,
    required double assetsTotal,
    required double liabilitiesTotal,
    required double netProfit,
  }) {
    if (assetsTotal.abs() > 0.001) return true;
    if (liabilitiesTotal.abs() > 0.001) return true;
    if (netProfit.abs() > 0.001) return true;

    for (final item in [...assets, ...liabilities]) {
      if (item.isHeader) continue;
      if (item.amount.abs() > 0.001) return true;
    }
    return false;
  }
}
