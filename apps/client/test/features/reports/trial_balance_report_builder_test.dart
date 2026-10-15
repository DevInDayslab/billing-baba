import 'package:billing_baba/features/reports/utils/trial_balance_report_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds balanced trial balance with sales and purchases', () {
    final report = TrialBalanceReportBuilder.build(
      openingCash: 1000,
      closingCash: 2500,
      cashReceived: 2000,
      cashPaid: 500,
      receivableOpening: 500,
      receivableClosing: 800,
      payableOpening: 200,
      payableClosing: 300,
      purchaseTotal: 1500,
      purchaseReturnTotal: 100,
      salesTotal: 5000,
      salesReturnTotal: 200,
      expenseTotal: 400,
      stockValue: 3000,
      partyOpening: 1000,
      netProfit: 1200,
    );

    expect(report.rows, isNotEmpty);
    expect(report.isBalanced, isTrue);
    expect(
      TrialBalanceReportBuilder.hasMeaningfulActivity(
        rows: report.rows,
        totalDebit: report.totalDebit,
        totalCredit: report.totalCredit,
      ),
      isTrue,
    );
  });

  test('hasMeaningfulActivity is false for empty report', () {
    final report = TrialBalanceReportBuilder.build(
      openingCash: 0,
      closingCash: 0,
      cashReceived: 0,
      cashPaid: 0,
      receivableOpening: 0,
      receivableClosing: 0,
      payableOpening: 0,
      payableClosing: 0,
      purchaseTotal: 0,
      purchaseReturnTotal: 0,
      salesTotal: 0,
      salesReturnTotal: 0,
      expenseTotal: 0,
      stockValue: 0,
      partyOpening: 0,
      netProfit: 0,
    );

    expect(
      TrialBalanceReportBuilder.hasMeaningfulActivity(
        rows: report.rows,
        totalDebit: report.totalDebit,
        totalCredit: report.totalCredit,
      ),
      isFalse,
    );
  });
}
