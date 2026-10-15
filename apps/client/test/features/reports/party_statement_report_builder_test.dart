import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:billing_baba/features/reports/utils/party_statement_report_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters entries by period and computes running balance', () {
    final ledger = PartyLedgerModel(
      partyId: 'p1',
      summary: const PartyLedgerSummaryModel(
        openingBalance: 100,
        outstanding: 250,
        receiveAmount: 250,
        payableAmount: 0,
        isActive: true,
        totalSales: 500,
        totalPurchases: 0,
        totalPayments: 150,
      ),
      transactions: [
        PartyLedgerTransactionModel(
          id: 't1',
          date: DateTime(2026, 10, 1),
          createdAt: DateTime(2026, 10, 1, 10),
          type: 'Sale',
          entryType: 'sale',
          source: 'sales_documents',
          sourceType: 'tax_invoice',
          debit: 200,
          credit: 0,
          balanceAfter: 300,
          total: 200,
          balance: 300,
          referenceNumber: 'INV-1',
        ),
        PartyLedgerTransactionModel(
          id: 't2',
          date: DateTime(2026, 10, 5),
          createdAt: DateTime(2026, 10, 5, 11),
          type: 'Payment',
          entryType: 'payment',
          source: 'payments',
          sourceType: 'payment',
          debit: 0,
          credit: 50,
          balanceAfter: 250,
          total: 50,
          balance: 250,
          referenceNumber: 'RCPT-1',
        ),
        PartyLedgerTransactionModel(
          id: 't3',
          date: DateTime(2026, 9, 15),
          createdAt: DateTime(2026, 9, 15, 9),
          type: 'Sale',
          entryType: 'sale',
          source: 'sales_documents',
          sourceType: 'tax_invoice',
          debit: 400,
          credit: 0,
          balanceAfter: 500,
          total: 400,
          balance: 500,
          referenceNumber: 'INV-0',
        ),
      ],
    );

    final report = PartyStatementReportBuilder.build(
      ledger: ledger,
      query: ReportQuery(
        period: ReportPeriod.custom,
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 10, 31),
        partyId: 'p1',
      ),
    );

    expect(report.entries, hasLength(2));
    expect(report.entries.first.refNo, 'INV-1');
    expect(report.entries.first.balance, 700);
    expect(report.entries.last.balance, 650);
    expect(report.summary.totalMoneyIn, 50);
    expect(report.summary.totalReceivable, 250);
    expect(report.summary.totalSale, 500);
  });
}
