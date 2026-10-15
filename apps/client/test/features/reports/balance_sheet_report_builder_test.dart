import 'package:billing_baba/features/reports/utils/balance_sheet_report_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds balanced balance sheet with assets and liabilities', () {
    final report = BalanceSheetReportBuilder.build(
      cash: 5000,
      receivable: 2000,
      payable: 1500,
      stockValue: 3000,
      netProfit: 800,
      partyOpening: 4000,
      openingCash: 3000,
      openingReceivable: 1000,
      openingPayable: 500,
      openingStock: 3000,
      asOn: DateTime(2026, 10, 13),
    );

    expect(report.assets, isNotEmpty);
    expect(report.liabilities, isNotEmpty);
    expect(report.isBalanced, isTrue);
    expect(
      BalanceSheetReportBuilder.hasMeaningfulActivity(
        assets: report.assets,
        liabilities: report.liabilities,
        assetsTotal: report.assetsTotal,
        liabilitiesTotal: report.liabilitiesTotal,
        netProfit: report.netProfit,
      ),
      isTrue,
    );
  });

  test('hasMeaningfulActivity is false for empty balance sheet', () {
    final report = BalanceSheetReportBuilder.build(
      cash: 0,
      receivable: 0,
      payable: 0,
      stockValue: 0,
      netProfit: 0,
      partyOpening: 0,
      openingCash: 0,
      openingReceivable: 0,
      openingPayable: 0,
      openingStock: 0,
      asOn: DateTime(2026, 10, 13),
    );

    expect(
      BalanceSheetReportBuilder.hasMeaningfulActivity(
        assets: report.assets,
        liabilities: report.liabilities,
        assetsTotal: report.assetsTotal,
        liabilitiesTotal: report.liabilitiesTotal,
        netProfit: report.netProfit,
      ),
      isFalse,
    );
  });
}
