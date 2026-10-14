import 'package:billing_baba/features/reports/utils/profit_loss_report_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds sale revenue and net profit from local totals', () {
    final report = ProfitLossReportBuilder.build(
      netSales: 12156.30,
      netPurchases: 0,
      expenseTotal: 0,
    );

    expect(report.netProfit, 12156.30);
    final revenue = report.items
        .where((item) => item.particular == 'Sale (Revenue) Account')
        .single;
    expect(revenue.amount, 12156.30);
    expect(
      ProfitLossReportBuilder.hasMeaningfulActivity(
        items: report.items,
        netProfit: report.netProfit,
      ),
      isTrue,
    );
  });

  test('hasMeaningfulActivity is false for empty API-shaped report', () {
    final report = ProfitLossReportBuilder.build(
      netSales: 0,
      netPurchases: 0,
      expenseTotal: 0,
    );

    expect(
      ProfitLossReportBuilder.hasMeaningfulActivity(
        items: report.items,
        netProfit: report.netProfit,
      ),
      isFalse,
    );
  });
}
