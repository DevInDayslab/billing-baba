import 'package:billing_baba/features/export/application/adapters/party_ledger_export_adapter.dart';
import 'package:billing_baba/features/export/data/excel_exporter.dart';
import 'package:billing_baba/features/export/models/export_format.dart';
import 'package:billing_baba/features/export/models/export_request.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildPartyLedgerExportSheet', () {
    test('includes all party transactions in export rows', () {
      final transactions = [
        PartyLedgerTransactionModel(
          id: '1',
          date: DateTime(2026, 7, 1),
          createdAt: DateTime(2026, 7, 1, 10, 30),
          type: 'Sale Invoice',
          entryType: 'sale',
          source: 'sales_documents',
          sourceType: 'tax_invoice',
          debit: 1500,
          credit: 0,
          balanceAfter: 1500,
          total: 1500,
          balance: 1500,
          referenceNumber: 'INV-001',
          status: 'Unpaid',
        ),
        PartyLedgerTransactionModel(
          id: '2',
          date: DateTime(2026, 7, 2),
          createdAt: DateTime(2026, 7, 2, 15),
          type: 'Payment In',
          entryType: 'payment',
          source: 'payments',
          sourceType: 'payment_in',
          debit: 0,
          credit: 500,
          balanceAfter: 1000,
          total: 500,
          balance: 1000,
          referenceNumber: 'RCPT-001',
        ),
      ];

      final sheet = buildPartyLedgerExportSheet(transactions: transactions);

      expect(sheet.name, 'Transactions');
      expect(sheet.rows.length, 2);
      expect(sheet.rows.first.cells.first, 'Sale Invoice');
      expect(sheet.rows.last.cells.first, 'Payment In');
    });

    test('produces non-empty xlsx bytes', () {
      final sheet = buildPartyLedgerExportSheet(
        transactions: [
          PartyLedgerTransactionModel(
            id: '1',
            date: DateTime(2026, 7, 1),
            createdAt: DateTime(2026, 7, 1, 10, 30),
            type: 'Sale Invoice',
            entryType: 'sale',
            source: 'sales_documents',
            sourceType: 'tax_invoice',
            debit: 1500,
            credit: 0,
            balanceAfter: 1500,
            total: 1500,
            balance: 1500,
            referenceNumber: 'INV-001',
          ),
        ],
      );

      final bytes = ExcelExporter().export(
        ExportRequest(
          sheets: [sheet],
          format: ExportFormat.xlsx,
          filenameBase: partyLedgerExportFilename('Acme Traders'),
        ),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(200));
    });
  });
}
