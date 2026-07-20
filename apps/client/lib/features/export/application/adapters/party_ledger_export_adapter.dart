import 'package:billing_baba/features/export/models/export_column.dart';
import 'package:billing_baba/features/export/models/export_row.dart';
import 'package:billing_baba/features/export/models/export_sheet.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';

ExportSheet buildPartyLedgerExportSheet({
  required List<PartyLedgerTransactionModel> transactions,
}) {
  return ExportSheet(
    name: 'Transactions',
    columns: const [
      ExportColumn(header: 'Type'),
      ExportColumn(header: 'Reference'),
      ExportColumn(header: 'Date/Time', type: ExportCellType.datetime),
      ExportColumn(header: 'Total', type: ExportCellType.currency),
      ExportColumn(header: 'Balance / Outstanding', type: ExportCellType.currency),
      ExportColumn(header: 'Due Date', type: ExportCellType.date),
      ExportColumn(header: 'Status'),
    ],
    rows: [
      for (final transaction in transactions)
        ExportRow([
          transaction.type,
          PartyModel.displayOrDash(transaction.referenceNumber),
          transaction.createdAt,
          _transactionTotal(transaction),
          _transactionBalance(transaction),
          transaction.dueDate,
          _transactionStatus(transaction),
        ]),
    ],
  );
}

double _transactionTotal(PartyLedgerTransactionModel transaction) =>
    transaction.total > 0
    ? transaction.total
    : (transaction.debit > 0 ? transaction.debit : transaction.credit);

double _transactionBalance(PartyLedgerTransactionModel transaction) =>
    transaction.balance > 0 || transaction.balanceAfter == 0
    ? transaction.balance
    : transaction.balanceAfter;

String _transactionStatus(PartyLedgerTransactionModel transaction) {
  final status = transaction.status?.trim();
  if (status != null && status.isNotEmpty) {
    return status;
  }

  final paymentStatus = transaction.paymentStatus?.trim();
  if (paymentStatus != null && paymentStatus.isNotEmpty) {
    return paymentStatus;
  }

  return switch (transaction.entryType) {
    'payment' => transaction.isPayment ? 'Unpaid' : 'Paid',
    'return' => 'Returned',
    _ => '—',
  };
}

String partyLedgerExportFilename(String partyName) {
  final safeName = partyName.replaceAll(RegExp(r'[^\w\-]+'), '_');
  return safeName.isEmpty ? 'Party_Ledger' : 'Party_Ledger_$safeName';
}
